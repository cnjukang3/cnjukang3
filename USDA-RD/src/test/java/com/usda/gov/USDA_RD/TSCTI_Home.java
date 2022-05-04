package com.usda.gov.USDA_RD;

import static com.usda.gov.USDA_RD.pages.BasePage.driver;

import org.testng.Reporter;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import com.usda.gov.USDA_RD.utility.Utils;

public class TSCTI_Home {

	// declare variables
	String browser_name;
	String URL;
	
	Utils util = new Utils();
	
	// Initialize and start the browser
	@BeforeTest
	public void setup() throws Exception {
		// initialize variables
		browser_name = "chome";
		URL = "https://www.tscti.com/";
		// pass the browser name to a method
		util.start_browser(browser_name);
		// navigate to the URL
		util.navigate_to_url(URL);
		// get system info
	    util.systemInfo();
		Reporter.log("Browser start...");
		// Log the environment
		util.get_env(URL);
		Reporter.log("Application is up and running!");
	}
	
	
	@Test
	public void test01() throws Exception {
		// test method
		Reporter.log("The test steps will be executed here.", true);
	}
	
	@AfterTest
	public void close_browser() {
		driver.quit();
	}
}
