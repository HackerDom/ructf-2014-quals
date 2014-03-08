using System;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using log4net;
using mssngrrrtest.utils;
using OpenQA.Selenium;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Support.Extensions;

namespace mssngrrrtest
{
	internal class Checker
	{
		public Checker(DriversPool driversPool)
		{
			this.driversPool = driversPool;
		}

		public void RunLoop()
		{
			while(true)
			{
				try
				{
					Thread.Sleep(1000);
					CheckNewItems();
				}
				catch(Exception e)
				{
					log.Error(e);
				}
			}
		}

		private void CheckNewItems()
		{
			while(true)
			{
				var msgs = DbStorage.FindNotReadMessages(Settings.UserId, 20);
				if(msgs.Count == 0)
					break;

				log.InfoFormat("Found {0} new items", msgs.Count);
				msgs.AsParallel().WithMergeOptions(ParallelMergeOptions.NotBuffered).ForAll(msgid => driversPool.UsingDriver(driver => DoIt.WithRetries(() =>
				{
					log.InfoFormat("Check item {0}", msgid.ToString("N"));
					ClearBrowserData(driver);
					SetCookies(driver);
					Check(driver, msgid);
					DoIt.Wait(() => DoIt.TryOrDefault(() => driver.ExecuteJavaScript<bool>("return $.isReady;")), 100, Settings.MaxWaitDocReady);
					Thread.Sleep(Settings.WaitAsyncs);
					driver.Navigate().GoToUrl(Settings.BaseUri);
					DbStorage.SetMessageRead(msgid);
					log.InfoFormat("Set item {0} read", msgid.ToString("N"));
				}, string.Format("Failed to process item {0}", msgid))));
			}
		}

		private static void Check(RemoteWebDriver driver, Guid msgid)
		{
			driver.Navigate().GoToUrl(new Uri(Settings.BaseUri, "/messages"));
			driver.Navigate().GoToUrl(new Uri(Settings.BaseUri, "/preview?id=" + msgid.ToString("N")));
		}

		private static void SetCookies(RemoteWebDriver driver)
		{
			driver.Manage().Cookies.AddCookie(new Cookie("secureid", Settings.UserIdCookie));
			driver.Manage().Cookies.AddCookie(new Cookie("flag", Settings.Flag));
			var cookies = driver.ExecuteJavaScript<string>("return document.cookie;");
			if(!Regex.IsMatch(cookies, @"flag=" + Regex.Escape(Settings.Flag)))
				log.WarnFormat("VALID FLAG COOKIE NOT FOUND!");
			if(!Regex.IsMatch(cookies, @"secureid=" + Regex.Escape(Settings.UserIdCookie)))
				log.WarnFormat("VALID SECUREID COOKIE NOT FOUND!");
		}

		private static void ClearBrowserData(RemoteWebDriver driver)
		{
			driver.Manage().Cookies.DeleteAllCookies();
			driver.ExecuteScript("window.localStorage.clear();window.sessionStorage.clear();");
		}

		private static readonly ILog log = LogManager.GetLogger(typeof(Checker));
		private readonly DriversPool driversPool;
	}
}