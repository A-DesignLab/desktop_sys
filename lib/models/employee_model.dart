class EmployeeModel
{
  late String uId;
  late String email;
  late String name;
  late String phone;
  late String jobTitle;
  late String image;
  late String address;
  late String department;
  late String employeeType;



  EmployeeModel({
    required this.uId,
    required this.email,
    required this.name,
    required this.phone,
    required this.jobTitle,
    required this.image,
    required this.address,
    required this.department,
    required this.employeeType,

  });

  EmployeeModel.fromJson(Map<String, dynamic> json)
  {
    uId = json['uId '];
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    image = json['image '];
    address = json['address '];
    jobTitle = json['job_title '];
    department = json['department_id'];
    employeeType = json['employee_type '];

  }

  Map<String, dynamic> toMap ()
  {
    return {
      'uId' : uId,
      'email' : email,
      'name' : name,
      'phone' : phone,
      'image' : image,
      'address' : address,
      'job_title' : jobTitle,
      'department_id' : department,
      'employee_type' : employeeType,
    };
  }

}