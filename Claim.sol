// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Hospital.sol";
import "./Interface.sol";
contract Claim is Hospital,Interface {
    //number 1: define varible
   //1-1 deifin address FDA & Hospital
    address public hospitalAdmin;
    address public FDAAdmin;
     
    //1-2 define claim variable
     enum drugnames{
       // Metformin
       Empty,//0
       METFORMINCHIMIDAROU500MG,//1
       METFORMINFAKHER500MG,//2
       METFORMINMAHBANDAROU500MG,//3
       METFORMINSAMISAZ500MG,//4
       OSVEMETFORMIN1000MG,//5
        //Linagliptin
       LINAGLIPTINABURAIHAN5MG,//6
       LINAGLIPTINTEHRANDAROU5mg,//7
       LINAGLIPTINDORSA5mg, //8
       LINAGLIPTINSAMISAZ5MG,//9
        //EMPAGLFLOZIN
        EMPAGLFLOZINALBORZDAROU25mg,//10
        EMPAGLFLOZINALBORZDAROU10mg,//11
        EMPAGLIFLOZINKHARAZMI10MG,//12
        EMPAGLIFLOZINPHARMACHEMI25MG,//13
        EMPAGLIFLOZINREYHANEH25mg//14
    }
    enum complictions{
      Empty,//0
        Headacheaggravated,//1
        Vertigoaggavated,//2
        Muscleweaknessaggravated,//3
        Asthenia,//4
        Comahyperglycaemic,//5
        Arrhythmia,//6
        Chestpainaggraveted//7
    }
enum Reductioncomplicationsdiscontinued{//Reductionofcomplicationsafterstoppingthedrug
empty,//0
Yes,//1
NO,//2
notbeendiscontinued,//3
Dontknow//4
}
enum complicationsrepeatedusedrug {//occurrenceofcomplicationsafterrepeateduseofthedrug;
empty,
Yes,
NO,
Notusedagain,
Dontknow
}
enum hospitalization {//drugcomplicationhasledtothehospitalizationofthepatient
empty,
Yes,
NO,
Dontknow
}
enum FinalyComplications  {//FinalydrugComplication
empty,//0
recovery,//1
nonrecovery,//2
disability,//3
death//4
}
 enum Approved{
     dontcall,//0
     accept,//1
     refer//2
   } 
 struct Record {
        uint8 ID;
        drugnames drugname;
        string date;
        uint8 duration;
        //uint time;
        complictions typecompliction;
        Reductioncomplicationsdiscontinued reductionofcomplicationsafterstoppingthedrug;
        complicationsrepeatedusedrug occurrenceofcomplicationsafterrepeateduseofthedrug; 
        hospitalization drugcomplicationhasledtothehospitalizationofthepatient;
        FinalyComplications finalyComplication;
        uint256 signatureCount;
         bool isValue;
     mapping (address => uint256) signatures;   address pAddr;   
    }
 Approved _approved;

    constructor(address _hospitaladmin) {
        FDAAdmin = msg.sender;
       hospitalAdmin  = _hospitaladmin;
    }
   //1-3 Mapping to store records
    mapping (uint256=> Record) public _records;
    uint256[] public recordsArr;
    event recordCreated(
        uint8 ID,
        drugnames drugname,
        string date,
        uint8 duration,
        //uint time,
      complictions typecompliction,
       Reductioncomplicationsdiscontinued reductionofcomplicationsafterstoppingthedrug,
        complicationsrepeatedusedrug occurrenceofcomplicationsafterrepeateduseofthedrug,
        hospitalization drugcomplicationhasledtothehospitalizationofthepatient,
        FinalyComplications finalyComplication
    );
 event recordSigned(
        uint8 ID,
        drugnames drugname,
        string date,
        //uint time,
        uint8 duration,
        complictions typecompliction,
        Reductioncomplicationsdiscontinued reductionofcomplicationsafterstoppingthedrug,
        complicationsrepeatedusedrug occurrenceofcomplicationsafterrepeateduseofthedrug,
        hospitalization drugcomplicationhasledtothehospitalizationofthepatient,
        FinalyComplications finalyComplication
 );
  modifier signOnly {
        require (msg.sender == hospitalAdmin || msg.sender == FDAAdmin, "You are not authorized to sign this.");
        _;
    }
     modifier checkAuthBeforeSign(uint256 _ID) {
        require(_records[_ID].isValue, "Recored does not exist");// چک کردن اینکه  رکورد توسط بیمار ایجادشده باشه
        require(address(0) != _records[_ID].pAddr, "Address is zero");// رکورد ایجادشده توسط فرد جعلی ادرس صفر ایجاد نشده باشه
        require(msg.sender != _records[_ID].pAddr, "You are not authorized to perform this action");//چک کردن این که فرد تایید کننده حتما سازمان غذا و دارو و بیمارستان باشد
        require(_records[_ID].signatures[msg.sender] != 1, "Same person cannot sign twice.");// بیمارستان و سازمان غذا و دارو هرکدام یکبار اجازه تایید کردن دارند
        _;
    }
     modifier validateRecord(uint256 _ID) {
        // Only allows new records to be created
        require(!_records[_ID].isValue, "Record with this ID already exists");
        _;
  
}
 function newRecord ( 
       uint8 _ID,
       drugnames _drugname,
        string memory _date,
        //uint time,
        uint8 _duration,
       complictions _typecompliction,
         Reductioncomplicationsdiscontinued _reductionofcomplicationsafterstoppingthedrug,
        complicationsrepeatedusedrug _occurrenceofcomplicationsafterrepeateduseofthedrug, 
        hospitalization _drugcomplicationhasledtothehospitalizationofthepatient,
        FinalyComplications _finalyComplication
    )
     validateRecord(_ID) public {
        Record storage _newrecord = _records[_ID];
        _newrecord.pAddr = msg.sender;
        _newrecord.ID = _ID;
        _newrecord.drugname= _drugname;
        _newrecord.typecompliction = _typecompliction;
        _newrecord.date = _date;
        //_newrecord.time = _time;
         _newrecord.duration = _duration;
         _newrecord.reductionofcomplicationsafterstoppingthedrug =_reductionofcomplicationsafterstoppingthedrug;
        _newrecord. occurrenceofcomplicationsafterrepeateduseofthedrug = _occurrenceofcomplicationsafterrepeateduseofthedrug;
        _newrecord.drugcomplicationhasledtothehospitalizationofthepatient = _drugcomplicationhasledtothehospitalizationofthepatient;
          _newrecord.finalyComplication = _finalyComplication;
        _newrecord.isValue = true;
        _newrecord.signatureCount = 0;
        
        recordsArr.push(_ID);
        emit recordCreated(
        _newrecord.ID,
         _drugname,
        _date,
       _duration,
         _typecompliction,
         //_time,
        
        _reductionofcomplicationsafterstoppingthedrug,
         _occurrenceofcomplicationsafterrepeateduseofthedrug,
        _drugcomplicationhasledtothehospitalizationofthepatient,
      _finalyComplication );
      
    }
     function signRecord(uint256 _ID) signOnly checkAuthBeforeSign(_ID) public {
        Record storage records = _records[_ID];
        _records[_ID].signatures[msg.sender] = 1;
        records.signatureCount++;
// ایجاد ایونت رکورد جدید بعد از تایید هر دو سازمان
        // Checks if the record has been signed by both the authorities to process Pharmaceutical claim
        if (records.signatureCount == 2)
       emit recordSigned(records.ID,records.drugname,
      records.date,
      records.duration,
      records.typecompliction,
       records.reductionofcomplicationsafterstoppingthedrug,
       records.occurrenceofcomplicationsafterrepeateduseofthedrug,
       records.drugcomplicationhasledtothehospitalizationofthepatient,
       records.finalyComplication
   
       );
       }
    mapping(address=>mapping(bytes32=>Approved )) public operator;
 
  function setApprovalForpharmaceuticalCompany(Approved _approved,bytes32 _fileHash) public  {
     require(FDAAdmin ==msg.sender,"You are not authorized to perform this action");
     operator[msg.sender][_fileHash]= _approved;
     }
}
