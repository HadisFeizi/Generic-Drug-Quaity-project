// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ClaimNew is HealthCare, Systeminterface {
    //number 1: define varible
   //1-1 deifin address FDA & Hospital
    address public hospitalAdmin;
    address public FDAAdmin;
     
    //1-2 define claim variable
    enum drugnames{
       // Metformin
     METFORMINCHIMIDAROU500MG,//0
     METFORMINFAKHER500MG,//1
     METFORMINMAHBANDAROU500MG,//2
     METFORMINSAMISAZ500MG,//3
     OSVEMETFORMIN1000MG,//4
        //Linagliptin
       LINAGLIPTINABURAIHAN5MG,//5
       LINAGLIPTINTEHRANDAROU5mg,//6
       LINAGLIPTINDORSA5mg, //7
       LINAGLIPTINSAMISAZ5MG,//8
        //EMPAGLFLOZIN
        EMPAGLFLOZINALBORZDAROU25mg,//9
        EMPAGLFLOZINALBORZDAROU10mg,//10
        EMPAGLIFLOZINKHARAZMI10MG,//11
        EMPAGLIFLOZINPHARMACHEMI25MG,//12
        EMPAGLIFLOZINREYHANEH25mg//13
    }
    enum typecomplictions{
        Headacheaggravated,//0
        Vertigoaggavated,//1
        Muscleweaknessaggravated,//2
        Asthenia,//3
        Comahyperglycaemic,//4
        Arrhythmia,//5
        Chestpainaggraveted//6
    }

    struct Record {
        uint8 ID;
        drugnames drugname;
        string date;
        uint8 duration;
        //uint time;
        typecomplictions typecompliction;
        uint8 Reductionofcomplicationsafterstoppingthedrug;// (1:خیر) , (2: بله)،(3: دارو قطع نشده)، (4 : نمیدانم)
        uint8 occurrenceofcomplicationsafterrepeateduseofthedrug; //(1:خیر)، (2: بله)،(3: دارو مجدد مصرف نگردیده است)،(4: نمی دانم)
        uint8  drugcomplicationhasledtothehospitalizationofthepatient;//(1: حیر)، (2: بله)، (3:نمی دانم)
        uint8 FinalydrugComplication;//(1:بهبودی )، (2: عدم بهبودی)، (3: نقص عضو)،(4: مرگ)
        uint256 signatureCount;
         bool isValue;
        address pAddr;   
    }
    mapping (address => uint256) signatures;
   uint8 _approved; //(0:فراخوانی نشده)،(1: پذیرش درخواست)،(2: عدم پذیرش درخواست)
   
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
       typecomplictions typecompliction,
        uint8 Reductionofcomplicationsafterstoppingthedrug,// (1:خیر) , (2: بله)،(3: دارو قطع نشده)، (4 : نمیدانم)
        uint8 occurrenceofcomplicationsafterrepeateduseofthedrug, //(1:خیر)، (2: بله)،(3: دارو مجدد مصرف نگردیده است)،(4: نمی دانم)
        uint8  drugcomplicationhasledtothehospitalizationofthepatient,//(1: حیر)، (2: بله)، (3:نمی دانم)
        uint8 FinalydrugComplication
    );
 event recordSigned(
        uint8 ID,
        drugnames drugname,
        string date,
        //uint time,
        uint8 duration,
        typecomplictions typecompliction,
        uint8 Reductionofcomplicationsafterstoppingthedrug,// (1:خیر) , (2: بله)،(3: دارو قطع نشده)، (4 : نمیدانم)
        uint8 occurrenceofcomplicationsafterrepeateduseofthedrug, //(1:خیر)، (2: بله)،(3: دارو مجدد مصرف نگردیده است)،(4: نمی دانم)
        uint8  drugcomplicationhasledtothehospitalizationofthepatient,//(1: حیر)، (2: بله)، (3:نمی دانم)
        uint8 FinalydrugComplication
 );
  modifier signOnly {
        require (msg.sender == hospitalAdmin || msg.sender == FDAAdmin, "You are not authorized to sign this.");
        _;
    }
     modifier checkAuthBeforeSign(uint256 _ID) {
        require(_records[_ID].isValue, "Recored does not exist");// چک کردن اینکه  رکورد توسط بیمار ایجادشده باشه
        require(address(0) != _records[_ID].pAddr, "Address is zero");// رکورد ایجادشده توسط فرد جعلی ادرس صفر ایجاد نشده باشه
        require(msg.sender != _records[_ID].pAddr, "You are not authorized to perform this action");//چک کردن این که فرد تایید کننده حتما سازمان غذا و دارو و بیمارستان باشد
        require(signatures[msg.sender] != 1, "Same person cannot sign twice.");// بیمارستان و سازمان غذا و دارو هرکدام یکبار اجازه تایید کردن دارند
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
       typecomplictions _typecompliction,
        uint8 _Reductionofcomplicationsafterstoppingthedrug,// (1:خیر) , (2: بله)،(3: دارو قطع نشده)، (4 : نمیدانم)
        uint8 _occurrenceofcomplicationsafterrepeateduseofthedrug, //(1:خیر)، (2: بله)،(3: دارو مجدد مصرف نگردیده است)،(4: نمی دانم)
        uint8  _drugcomplicationhasledtothehospitalizationofthepatient,//(1: حیر)، (2: بله)، (3:نمی دانم)
        uint8 _FinalydrugComplication
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
         _newrecord.Reductionofcomplicationsafterstoppingthedrug =_Reductionofcomplicationsafterstoppingthedrug;
        _newrecord. occurrenceofcomplicationsafterrepeateduseofthedrug = _occurrenceofcomplicationsafterrepeateduseofthedrug;
        _newrecord.drugcomplicationhasledtothehospitalizationofthepatient = _drugcomplicationhasledtothehospitalizationofthepatient;
          _newrecord.FinalydrugComplication = _FinalydrugComplication;
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
        
        _Reductionofcomplicationsafterstoppingthedrug,
         _occurrenceofcomplicationsafterrepeateduseofthedrug,
        _drugcomplicationhasledtothehospitalizationofthepatient,
      _FinalydrugComplication );
      
    }
     function signRecord(uint256 _ID) signOnly checkAuthBeforeSign(_ID) public {
        Record storage records = _records[_ID];
        signatures[msg.sender] = 1;
        records.signatureCount++;
// ایجاد ایونت رکورد جدید بعد از تایید هر دو سازمان
        // Checks if the record has been signed by both the authorities to process Pharmaceutical claim
        if (records.signatureCount == 2)
       emit recordSigned(records.ID,records.drugname,
      records.date,
      records.duration,
      records.typecompliction,
       records.Reductionofcomplicationsafterstoppingthedrug,
       records.occurrenceofcomplicationsafterrepeateduseofthedrug,
       records.drugcomplicationhasledtothehospitalizationofthepatient,
       records.FinalydrugComplication
   
       );
       }
    mapping(address=>mapping(address=>uint8 )) internal operator;
 
  function setApprovalForpharmaceuticalCompany(address PHid,uint8 _approved) public  {
     require(PHid !=msg.sender);
     require(FDAAdmin ==msg.sender,"You are not authorized to perform this action");
     operator[msg.sender][PHid]= _approved;
     }
     // دریافت نتیجه درخواست تاییدیه مدارک 
function getresultapproved(address PHid) public view returns(uint8 ){
    require(PHid ==msg.sender);
    return(_approved);
}

}