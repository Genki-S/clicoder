Feature: AOJ
	In order to make it easy to solve a problem from AOJ
	As a CLI
	I want to provide commands to perform common tasks

	Scenario: Start a new problem
		When I run `clicoder aoj new 0`
		Then the output should contain "created directory 0000"
