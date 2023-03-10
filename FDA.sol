pragma solidity ^0.8.0;

contract FDA {
    mapping (address => FDA) internal FoodandDrugAdministration;
    mapping (address => mapping(address => uint)) internal FDATopharmaceuticalCompany;
    
    struct FDA {
        string name;
        address ID;
        address[] pharmaceuticalCompany_list;
    }
    
    modifier checkFDA(address ID) {
        FDA storage f = FoodandDrugAdministration[ID];
        require(f.ID != address(0x0));//check if FDAadmin exist
        _;
    }
    
    function getFDAInfo() public view checkFDA(msg.sender) returns(string memory, address[] memory){
        FDA storage f = FoodandDrugAdministration[msg.sender];
        return (f.name, f.pharmaceuticalCompany_list);
    }
    
    function signupFDA(string memory _name) public {
        FDA storage f = FoodandDrugAdministration[msg.sender];
        require(keccak256(abi.encode(_name)) != keccak256(""));
        require(!(f.ID != address(0x0)));

        FoodandDrugAdministration[msg.sender] = FDA({name:_name,ID:msg.sender,pharmaceuticalCompany_list:new address[](0)});
    }    
    
}