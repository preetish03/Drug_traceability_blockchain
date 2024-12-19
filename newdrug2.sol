// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugTraceability {

    struct Drug {
        uint id;
        string name;
        string manufacturerName;
        string wholesaler;
        string pharmacist;
        string patient;
    }

    mapping(uint => Drug) public drugs;
    uint[] public drugIds;

    address public admin;
    address public manufacturer;
    address public wholesaler;
    address public pharmacist;
    address public patient;

    mapping(address => uint) public otp;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyManufacturer() {
        require(msg.sender == manufacturer, "Only manufacturer can perform this action");
        _;
    }

    modifier onlyWholesaler() {
        require(msg.sender == wholesaler, "Only wholesaler can perform this action");
        _;
    }

    modifier onlyPharmacist() {
        require(msg.sender == pharmacist, "Only pharmacist can perform this action");
        _;
    }

    modifier onlyPatient() {
        require(msg.sender == patient, "Only patient can perform this action");
        _;
    }

    constructor(address _manufacturer, address _wholesaler, address _pharmacist, address _patient) {
        admin = msg.sender;
        manufacturer = _manufacturer;
        wholesaler = _wholesaler;
        pharmacist = _pharmacist;
        patient = _patient;
    }

    function generateOtp() internal returns (uint) {
        uint _otp = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000000;
        otp[msg.sender] = _otp;
        return _otp;
    }

    function getOtp() public returns (uint) {
        return generateOtp();
    }

    function addDrug(
        uint _id,
        string memory _name,
        string memory _manufacturerName,
        string memory _wholesalerName,
        string memory _pharmacistName,
        string memory _patientName
    ) public onlyManufacturer {
        Drug memory newDrug = Drug({
            id: _id,
            name: _name,
            manufacturerName: _manufacturerName,
            wholesaler: _wholesalerName,
            pharmacist: _pharmacistName,
            patient: _patientName
        });
        drugs[_id] = newDrug;
        drugIds.push(_id);
    }

    function getDrug(uint _id, uint _otp) public view returns (
        uint drugId,
        string memory drugName,
        string memory drugManufacturerName,
        string memory drugWholesaler,
        string memory drugPharmacist,
        string memory drugPatient
    ) {
        require(otp[msg.sender] == _otp, "Invalid OTP");
        Drug memory d = drugs[_id];
        return (
            d.id,
            d.name,
            d.manufacturerName,
            d.wholesaler,
            d.pharmacist,
            d.patient
        );
    }

    function getAllDrugs(uint _otp) public view returns (Drug[] memory) {
        require(otp[msg.sender] == _otp, "Invalid OTP");
        Drug[] memory result = new Drug[](drugIds.length);
        for (uint i = 0; i < drugIds.length; i++) {
            result[i] = drugs[drugIds[i]];
        }
        return result;
    }

    function transferDrug(
        uint _id,
        string memory _newWholesaler,
        string memory _newPharmacist,
        string memory _newPatient,
        uint _otp
    ) public {
        require(otp[msg.sender] == _otp, "Invalid OTP");
        Drug storage d = drugs[_id];
        d.wholesaler = _newWholesaler;
        d.pharmacist = _newPharmacist;
        d.patient = _newPatient;
    }

    function deleteDrug(uint _id) public onlyAdmin {
        delete drugs[_id];
        for (uint i = 0; i < drugIds.length; i++) {
            if (drugIds[i] == _id) {
                drugIds[i] = drugIds[drugIds.length - 1];
                drugIds.pop();
                break;
            }
        }
    }
}
