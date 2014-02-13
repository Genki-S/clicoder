Feature: AOJ
	In order to make it easy to solve a problem from AOJ
	As a CLI
	I want to provide commands to perform common tasks

	Background:
		Given AOJ is stubbed with webmock

	Scenario: Start a new problem
		When I run `clicoder aoj new 1`
		Then the output should contain "created directory 0001"

	Scenario: Build a program
		Given in a problem directory of number 1
		When I run `clicoder aoj build`
		Then the exit status should be 0
		And an executable should be generated

	Scenario: Run a program
		Given in a problem directory of number 1
		When I run `clicoder aoj build`
		And I run `clicoder aoj execute`
		Then the exit status should be 0
		And my answer should be output in my outputs directory

	Scenario: Judge wrong outputs
		Given in a problem directory of number 1
		When I run `clicoder aoj build`
		And I run `clicoder aoj execute`
		Given outputs are wrong
		When I run `clicoder aoj judge`
		Then the exit status should be 1
		And the output should contain "Wrong Answer"

	Scenario: Judge correct outputs
		Given in a problem directory of number 1
		When I run `clicoder aoj build`
		And I run `clicoder aoj execute`
		Given outputs are correct
		When I run `clicoder aoj judge`
		Then the exit status should be 0
		And the output should contain "Correct Answer"
