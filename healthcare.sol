pragma solidity ^0.8.0;

import "./doctor.sol";
import "./patient.sol";
import "./file.sol";

contract HealthCare is Doctor, Patient, File {
    address private owner;
    
    function healthCare() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /*برای چک کردن دسترسی به فایل با توجه به نقش کاربر اگر پزشک باشد
     باید حتما در لیست پزشکان بیمار وجود داشته باشد
     مطابقت هش فایل
     درصورت بیمار بودن کاربر مطابقت هش فایل بررسی میگردد
     */
    modifier checkFileAccess(string memory role, address id, bytes32 fileHashId, address pat) {
        uint pos;
        if(keccak256(abi.encode(role) )== keccak256("doctor")) {
            require(patientToDoctor[pat][id] > 0);
            pos = patientToFile[pat][fileHashId];
            require(pos > 0);   
        }
        else if(keccak256(abi.encode(role)) == keccak256("patient")) {
            pos = patientToFile[id][fileHashId];
            require(pos > 0);
        }
        _; 
    }
    // بررسی اینکه کاربران ادرس منطقی داشته باشند
    function checkProfile(address _user) public view onlyOwner returns(string memory, string memory){
        patient storage p = Patients[_user];
        doctor storage d = doctors[_user];
          
        if(p.id != address(0x0))
            return (p.name, 'patient');
        else if(d.id!= address(0x0))
            return (d.name, 'doctor');
        else
            return ('', '');
    }
  // اجازه دسترسی به پزشک برای دریافت اطلاعات بیمار
    function grantAccessToDoctor(address doctor_id) public checkPatient(msg.sender) checkDoctor(doctor_id) {
        patient storage p = Patients[msg.sender];
        doctor storage d = doctors[doctor_id];
        require(patientToDoctor[msg.sender][doctor_id] < 1);// this means doctor already been access
        p.doctor_list.push(doctor_id);// new length of array
        uint pos = p.doctor_list.length -1;
       patientToDoctor[msg.sender][doctor_id] = pos;
        d.patient_list.push(msg.sender);
    }
  // اضافه کردن فایل 
    function addFile(string memory _file_name, string memory _file_type, bytes32 _fileHash, string  memory _file_secret) public checkPatient(msg.sender) {
        patient storage p = Patients[msg.sender];

        require(patientToFile[msg.sender][_fileHash] < 1);
      
        hashToFile[_fileHash] = filesInfo({file_name:_file_name, file_type:_file_type,file_secret:_file_secret});
        p.files.push(_fileHash);
        uint pos =_fileHash.length -1;
       
       patientToFile[msg.sender][_fileHash] = pos;
    }
    // دریافت اطلاعات بیمار برای پزشک
    function getPatientInfoForDoctor(address pat) public view checkPatient(pat) checkDoctor(msg.sender) returns(string memory, uint8, address, bytes32[] memory){
        patient storage p = Patients[pat];

        require(patientToDoctor[pat][msg.sender] > 0);

        return (p.name, p.age, p.id, p.files);
    }
    
    /* دریافت اطلاعات محرمانه 
    function getFileSecret(bytes32 fileHashId, string role, address id, address pat) public view 
    checkFile(fileHashId) checkFileAccess(role, id, fileHashId, pat)
    returns(string) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_secret);
    }*/
// دریافت اطلاعات پزشک
    function getFileInfoDoctor(address doc, address pat, bytes32 fileHashId) public view 
    onlyOwner checkPatient(pat) checkDoctor(doc) checkFileAccess("doctor", doc, fileHashId, pat)
    returns(string memory, string memory) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_name, f.file_type);
    }
  // دریافت اطلاعات بیمار
   function getFileInfoPatient(address pat, bytes32 fileHashId) public view 
    onlyOwner checkPatient(pat) checkFileAccess("patient", pat, fileHashId, pat) returns(string memory, string memory) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_name, f.file_type);
    }
  
}