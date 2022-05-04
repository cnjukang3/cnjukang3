package com.usda.gov.USDA_RD.utility;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.openqa.selenium.Capabilities;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.testng.Reporter;

import com.usda.gov.USDA_RD.pages.BasePage;

public class Utils extends BasePage {

	// declare variable
	static InetAddress addr;
	static Capabilities cap;
	
	// default constructor
	public Utils() {}
	
	// super class constructor
	public Utils(WebDriver driver) {
		super(driver);
	}
	
	public void start_browser(String browser_name) throws IOException, Exception {
		 String user_dir = System.getProperty("user.dir");
		browser_name = "chrome"; 
		//System.out.println("User Dir: " + user_dir);
		if(browser_name == "chrome") {
			//System.out.println("Browser: " + browser_name);
			System.setProperty("webdriver.chrome.driver", user_dir+"/chromedriver.exe");
			// start the browser
			ChromeOptions options = new ChromeOptions();
			options.addArguments("--start-maximized");
			options.addArguments("--disable-popup-blocker");
			options.addArguments("ignore-certificate-errors");
			options.addArguments("excludeSwitches", "[enable-automation]");
			//options.addArguments("--headless");
			driver = new ChromeDriver(options);
		}else {

		}
	}
	
	public void get_env(String URL) {
		Reporter.log("Environment: " + URL, true);
	}
	
	public static void sleep(long milliseconds) throws InterruptedException {
		Thread.sleep(milliseconds);
	}
	
	public void navigate_to_url(String URL) throws InterruptedException {
		driver.navigate().to(URL);
		sleep(3000);
	}
	
	public static String get_current_datetime() throws Exception {
        final String df = "MM/dd/yyyy hh:mm:ss a";
        SimpleDateFormat format = new SimpleDateFormat(df);
        Date date = new Date(System.currentTimeMillis());
        String now = format.format(date);
        
        return now;
	}


	public static String get_OS() throws Exception {
		String os_name = System.getProperty("os.name");

		return os_name;
	}

	public static String get_username() throws Exception {
		String user_name = System.getProperty("user.name");
		
		return user_name.toUpperCase();
	}
	
	public static String get_version() throws Exception {
		String version = System.getProperty("java.version");
		
		return version;
	}
	
	public static String get_hostname() throws Exception {
		try {
			addr = InetAddress.getLocalHost();
			
		}catch(UnknownHostException e) {
			e.getMessage();
		}
		String hostname = addr.getHostName();
		
		return hostname.toUpperCase();
	}
	
	public static String get_ip_address() throws Exception {
		try {
			addr = InetAddress.getLocalHost();
		}catch (UnknownHostException e) {
			e.getMessage();
		}
		String ip = addr.getHostAddress();
		
		return ip;
	}
	
	public static String get_browser_name() throws Exception {
		cap = ((RemoteWebDriver)driver).getCapabilities();
		String browser_name = cap.getBrowserName().toString();
		
		return browser_name.substring(0, 1).toUpperCase() + browser_name.substring(1);
	}
	
	public static String get_browser_version() throws Exception {
		cap = ((RemoteWebDriver)driver).getCapabilities();
		String browser_version = cap.getVersion().toString();
		
		return browser_version.length() != 0 ? browser_version : "Browser version not found!";
	}
	
	
	public void systemInfo() throws Exception {
		String current_time = get_current_datetime();
	       String os_name = get_OS();
	       String ip_address = get_ip_address();
	       String user_name = get_username();
	       String java_version = get_version();
	       String browser_name = get_browser_name();
	       String browser_version = get_browser_version();
	       String current_t = "Current Date/Time:::";
	       String operating_system = "Operating System::::";
	       String ip_addr = "IP Address::::::::::";
	       String user_n = "User Name/OS User:::";
	       String java_v = "Java Version::::::::";
	       String browser_n = "Browser Name:::::::";
	       String browser_v = "Browser Version:::::";
	       String pipe = "|";
	       String nextline = "\n";
	       System.out.println();
	       System.out.println("+----------------------------< System Information >----------------------------+");
	       System.out.println("+------------------------------------------------------------------------------+");
	       System.out.printf("%-1s %10s %27s %29s %1s", pipe, current_t, current_time, pipe, nextline);
	       System.out.printf("%-1s %10s %15s %41s %1s", pipe, operating_system, os_name, pipe, nextline);
	       System.out.printf("%-1s %10s %20s %36s %1s", pipe, ip_addr, ip_address, pipe, nextline);
	       System.out.printf("%-1s %10s %22s %34s %1s", pipe, user_n, user_name, pipe, nextline);
	       System.out.printf("%-1s %10s %14s %42s %1s", pipe, java_v, java_version, pipe, nextline);
	       System.out.printf("%-1s %10s %12s %45s %1s", pipe, browser_n, browser_name, pipe, nextline);
	       System.out.printf("%-1s %10s %18s %38s %1s", pipe, browser_v, browser_version, pipe, nextline);
	      System.out.println("+------------------------------------------------------------------------------+");
	}
	
	
	public static void main(String[] args) {
		//
		System.out.println();
	}
	
}
