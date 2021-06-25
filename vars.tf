variable "db_tables" {
  type    = list(string)
  default = ["courses", "authors"]
}

variable "region" { default = "us-west-2" }
variable "bucketname" { default = "superbucket" }

// variable "http_method" {
//   type    = list(string)
//   default = ["PUT", "GET", "DELETE"]
// }

// variable "http_methods_lambda" {
//   default = {
//     "PUT"    = "updateCourse.py"
//     "GET"    = "getCourse.py"
//     "DELETE" = "deleteCourse.py"
//   }
//   type = map(string)
// }