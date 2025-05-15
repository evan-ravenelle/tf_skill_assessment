provider "aws" {
  region = "us-west-2"
}

//assume this is a different account
provider "aws" {
  alias  = "shared"
  region = "us-west-2"
}

provider "azurerm" {
  features {}
}
