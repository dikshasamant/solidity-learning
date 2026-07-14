// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract StudentManagement {

    struct Student{
        string name;uint256 age;
        uint256 rollNumber;
        string department;
        uint256 marks;
    }
    Student[] public students;

   mapping(uint256 => Student) public rollToStudent;

   function addStudent(string memory _name,uint256 _age,uint256 _rollNumber,string memory _department,uint256 _marks) public {
       require(rollToStudent[_rollNumber].rollNumber == 0,"Student already exists");
       require(bytes(_name).length > 0, "Name cannot be empty");
       require(_age > 0, "Invalid age");
       require(bytes(_department).length > 0, "Department cannot be empty");
       require(_marks <= 100, "Marks cannot exceed 100");
       Student memory newStudent = Student(_name, _age, _rollNumber, _department, _marks);
       students.push(newStudent);
       rollToStudent[_rollNumber] = newStudent;
   }

   function getStudent(uint256 _rollNumber) public view returns(Student memory) {
    require(rollToStudent[_rollNumber].rollNumber != 0,"Student does not exist");
    return rollToStudent[_rollNumber];
   }

   function studentCount() public view returns(uint256) {
    return students.length;
   }

   function getAllStudents() public view returns(Student[] memory) {
    return students;
   }

   function updateMarks(uint256 _rollNumber, uint256 _newMarks) public {
    require(rollToStudent[_rollNumber].rollNumber != 0,"Student does not exist");
    require(_newMarks <= 100, "Marks cannot exceed 100");
    rollToStudent[_rollNumber].marks = _newMarks;
    for ( uint256 i=0; i<students.length; i++ ) 
    {
        if (students[i].rollNumber == _rollNumber)
        {
            students[i].marks = _newMarks;
            break;
        }
    }
   }

}
