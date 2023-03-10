pragma solidity ^0.8.0;

contract Patient {
    mapping (address => patient) internal Patients;
    mapping (address => mapping (address => uint)) internal patientToDoctor;
    mapping (address => mapping (bytes32 => uint)) internal patientToFile;
    
    struct patient {
        string name;
        uint8 age;
        address id;
        bytes32[] files;// hashes of file that belong to this user for display purpose
        address [] doctor_list;
    }
    
    modifier checkPatient(address id) {
          patient storage p = Patients[id];
        require(p.id != address(0x0));//check if patient exist
        _;
    }
    
    function getPatientInfo() public view checkPatient(msg.sender) returns(string memory, uint8, bytes32[] memory, address[] memory) {
        patient storage p = Patients[msg.sender];
        return (p.name, p.age, p.files, p.doctor_list);
    }
    
    function signupPatient(string memory _name, uint8 _age) public {
        patient storage p = Patients[msg.sender];
        require(keccak256(abi.encode(_name)) != keccak256(""));
        require((_age > 0) && (_age < 100));
        require(!(p.id != address(0x0)));

        Patients[msg.sender] = patient({name:_name,age:_age,id:msg.sender,files:new bytes32[](0),doctor_list:new address[](0)});
    }

}