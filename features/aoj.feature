Feature: AOJ
	In order to make it easy to solve a problem from AOJ
	As a CLI
	I want to provide commands to perform common tasks

	Scenario: Start a new problem
		When I run `clicoder aoj new 1`
		Then the output should contain "created directory 0001"

	Scenario: Build a program
		Given in a problem directory of number 1
		When I run `clicoder aoj build`
		Then the exit status should be 0
		Then an executable should be generated

	Scenario: Run a program
		Given in a problem directory of number 1
		When I run `clicoder aoj build`
		When I run `clicoder aoj execute`
		Then the exit status should be 0
		Then my answer should be output in my outputs directory
