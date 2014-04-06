Feature: SampleSite
	In order to make it easy to deal with programming contests
	As a CLI
	I want to provide commands to perform common tasks

	Scenario: Start a new problem
		When I run `clicoder new sample_site`
		Then the output should contain "created directory working_directory"

	Scenario: Build a program
		Given in a problem directory
		When I run `clicoder build`
		Then an executable should be generated

	Scenario: Run a program
		Given in a problem directory
		When I run `clicoder build`
		And I run `clicoder execute`
		Then my answer should be output in my outputs directory

	Scenario: Judge without outputs
		Given in a problem directory
		When I run `clicoder judge`
		Then the output should contain "Wrong Answer"

	Scenario: Judge wrong outputs
		Given in a problem directory
		When I run `clicoder build`
		And I run `clicoder execute`
		Given outputs are wrong
		When I run `clicoder judge`
		Then the output should contain "Wrong Answer"

	Scenario: Judge correct outputs
		Given in a problem directory
		When I run `clicoder build`
		And I run `clicoder execute`
		Given outputs are correct
		When I run `clicoder judge`
		Then the output should contain "Correct Answer"

	Scenario: Judge outputs within allowed absolute error
		Given in a problem directory
		And the answer differs in second decimal place
		When I run `clicoder judge`
		Then the output should contain "Wrong Answer"

	Scenario: Judge outputs within allowed absolute error
		Given in a problem directory
		And the answer differs in second decimal place
		When I run `clicoder judge -d 2`
		Then the output should contain "Wrong Answer"

	Scenario: Judge outputs within allowed absolute error
		Given in a problem directory
		And the answer differs in second decimal place
		When I run `clicoder judge -d 1`
		Then the output should contain "Correct Answer"

	Scenario: Submit with user_id and password
		Given SampleSite submission url is stubbed with webmock
		And in a problem directory
		And Launchy.open is stubbed
		When I run `clicoder submit`
		Then the output should contain "Submission Succeeded."
		And the submission status should be opened

	Scenario: Submit without user_id and password
		Given SampleSite submission url is stubbed with webmock
		Given in a problem directory
		Given I don't have user_id and password
		When I run `clicoder submit`
		Then the output should contain "Submission Failed."

	Scenario: Open problem page with browser
		Given in a problem directory
		And Launchy.open is stubbed
		When I run `clicoder browse`
		Then the problem page should be opened
