pragma solidity ^0.8.0;

contract PharmaceuticalCompany {
    mapping (address => pharmaceuticalCompany) internal PharmaceuticalCompanies;
    mapping (address => mapping (address => uint)) internal pharmaceuticalCompanyToFDA;
    mapping (address => mapping (bytes32 => uint)) internal pharmaceuticalCompanyToFile;
    
 
    struct pharmaceuticalCompany {
        string name;
        uint8 drugID;
        address PHid;
        bytes32[] files;// hashes of file that belong to this user for display purpose
        address[] FDAadmin_list;
    }
    
    modifier checkpharmaceuticalCompany(address PHid) {
       pharmaceuticalCompany storage ph = PharmaceuticalCompanies[PHid];
        require(ph.PHid != address(0x0));//check if pharmaceuticalCompany exist
        _;
    }
    
    function getpharmaceuticalCompanyInfo() public view checkpharmaceuticalCompany(msg.sender) returns(string memory, uint8, bytes32[] memory, address[] memory) {
        pharmaceuticalCompany storage ph = PharmaceuticalCompanies[msg.sender];
        return (ph.name, ph.drugID, ph.files, ph.FDAadmin_list);
    }
    
    function signuppharmaceuticalCompany(string memory _name, uint8 _drugId) public {
        pharmaceuticalCompany storage ph = PharmaceuticalCompanies[msg.sender];
        require(keccak256(abi.encode(_name)) != keccak256(""));
        //require((_drugId > 0) && (_age < 100));
        require(!(ph.PHid != address(0x0)));

       PharmaceuticalCompanies[msg.sender] = pharmaceuticalCompany({name:_name,drugID:_drugId,PHid:msg.sender,files:new bytes32[](0),FDAadmin_list:new address[](0)});
    }
}