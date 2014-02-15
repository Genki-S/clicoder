Feature: AOJ
	In order to make it easy to solve a problem from AOJ
	As a CLI
	I want to provide commands to perform common tasks

	Background:
		Given AOJ is stubbed with webmock

	Scenario: Start a new problem
		When I run `clicoder new aoj 1`
		Then the output should contain "created directory 0001"

	Scenario: Build a program
		Given in a problem directory of number 1
		When I run `clicoder build`
		Then an executable should be generated

	Scenario: Run a program
		Given in a problem directory of number 1
		When I run `clicoder build`
		And I run `clicoder execute`
		Then my answer should be output in my outputs directory

	Scenario: Judge wrong outputs
		Given in a problem directory of number 1
		When I run `clicoder build`
		And I run `clicoder execute`
		Given outputs are wrong
		When I run `clicoder judge`
		Then the output should contain "Wrong Answer"

	Scenario: Judge correct outputs
		Given in a problem directory of number 1
		When I run `clicoder build`
		And I run `clicoder execute`
		Given outputs are correct
		When I run `clicoder judge`
		Then the output should contain "Correct Answer"

	Scenario: Submit with user_id and password
		Given in a problem directory of number 1
		When I run `clicoder submit`
		Then the output should contain "Submission Succeeded."

	Scenario: Submit without user_id and password
		Given in a problem directory of number 1
		Given I don't have user_id and password
		When I run `clicoder submit`
		Then the output should contain "Submission Failed."
