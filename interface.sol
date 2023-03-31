// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./pharmaceuticalCompany.sol";
import "./FDA.sol";
import "./file.sol";

contract Interface is FDA, PharmaceuticalCompany, File {
    address private owner;
    
    function systeminterface() public {
        owner = msg.sender;
    }
    
    modifier onlyOwnerInterface() {
        require(msg.sender == owner);
        _;
    }
    
    modifier checkFileAccessPharma(string memory role, address id, bytes32 fileHashId, address PHid) {
        uint pos;
        if(keccak256(abi.encode(role)) == keccak256("FDAAdmin")) {
            require(pharmaceuticalCompanyToFDA[PHid][id] > 0);
            pos = pharmaceuticalCompanyToFile[PHid][fileHashId];
            require(pos > 0);   
        }
        else if(keccak256(abi.encode(role)) == keccak256("pharmaceuticalCompany")) {
            pos = pharmaceuticalCompanyToFile[id][fileHashId];
            require(pos > 0);
        }
        _; 
    }
    
     function checkProfileInterface(address _user) public view onlyOwnerInterface returns(string memory, string memory){
       pharmaceuticalCompany storage ph = PharmaceuticalCompanies[_user];
        FDA storage f = FoodandDrugAdministration[_user];
          
        if(ph.PHid!= address(0x0))
            return (ph.name, 'pharmaceuticalCompany');
        else if(f.ID != address(0x0))
            return (f.name, 'FDA');
        else
            return ('', '');
    }
  
    function grantAccessToFDA(address ID) public checkpharmaceuticalCompany(msg.sender) checkFDA(ID) {
    pharmaceuticalCompany storage ph = PharmaceuticalCompanies[msg.sender];
        FDA storage f = FoodandDrugAdministration[ID];
        require(pharmaceuticalCompanyToFDA[msg.sender][ID] < 1);// this means FDA already been access
      ph.FDAadmin_list.push(ID);
        uint pos = ph.FDAadmin_list.length;  // new length of array

        pharmaceuticalCompanyToFDA[msg.sender][ID] = pos;
        f.pharmaceuticalCompany_list.push(msg.sender);
    }
  
    function addFilePharma(string memory _file_name, string memory _file_type, bytes32 _fileHash, string memory  _file_secret) public checkpharmaceuticalCompany(msg.sender) {
       pharmaceuticalCompany storage ph = PharmaceuticalCompanies[msg.sender];

        require(pharmaceuticalCompanyToFile[msg.sender][_fileHash] < 1);
      
        hashToFile[_fileHash] = filesInfo({file_name:_file_name, file_type:_file_type,file_secret:_file_secret});
         ph.files.push(_fileHash);
         uint pos = _fileHash.length;
        pharmaceuticalCompanyToFile[msg.sender][_fileHash] = pos;
    }
    
     function getpharmaceuticalCompanyToFDA(address PHid) public view checkpharmaceuticalCompany(PHid) checkFDA(msg.sender) returns(string memory, uint8, address, bytes32[]memory){
        pharmaceuticalCompany storage ph = PharmaceuticalCompanies[PHid];
        require(pharmaceuticalCompanyToFDA[PHid][msg.sender] > 0);
      return  (ph.name, ph.WE, ph.PHid, ph.files);
     }
    
   /* function getFileSecret(bytes32 fileHashId, string role, address FID, address PHid) public view 
    checkFile(fileHashId) checkFileAccess(role, FID, fileHashId, PHid)
    returns(string) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_secret);
    }*/

    
  
     function getFileInfopharmaceuticalCompany(address PHid, bytes32 fileHashId) public view 
    onlyOwnerInterface checkpharmaceuticalCompany(PHid) checkFileAccessPharma("pharmaceuticalCompany", PHid, fileHashId, PHid) returns(string memory, string memory) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_name, f.file_type);
     }
  
}
