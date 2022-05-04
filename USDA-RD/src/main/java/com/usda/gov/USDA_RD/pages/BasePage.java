package com.usda.gov.USDA_RD.pages;

import org.openqa.selenium.WebDriver;

public class BasePage {

	//declare the web driver
	public static WebDriver driver;
	
	//declare the default constructor
	public BasePage() {}
	
	//declare the parameterized constructor
	public BasePage(WebDriver driver) {
		BasePage.driver = driver;
	}

	// return the web driver
	public static WebDriver getDriver() {
		return driver;		
	}

	// set the web driver
	public static void setDriver(WebDriver driver) {
		BasePage.driver = driver;
	}
	
	
}
