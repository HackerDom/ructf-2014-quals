using System;
using System.Linq;
using System.Threading;
using log4net;
using irrsatest.utils;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Support.Extensions;

namespace irrsatest
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
				var msgs = DbStorage.FindNotReadMessages(Settings.Login, 20);
				if(msgs.Count == 0)
					break;

				log.InfoFormat("Found {0} new items", msgs.Count);
				msgs.AsParallel().WithMergeOptions(ParallelMergeOptions.NotBuffered).WithDegreeOfParallelism(driversPool.Count).ForAll(msgid => driversPool.UsingDriver(driver => DoIt.WithRetries(() =>
				{
					log.InfoFormat("Check item {0}", msgid.ToString("N"));
					ClearBrowserData(driver);
					Thread.Sleep(200);
					Login(driver);
					Thread.Sleep(200);
					Check(driver, msgid);
					Thread.Sleep(200);
					DoIt.Wait(() => DoIt.TryOrDefault(() => driver.ExecuteJavaScript<bool>("return $.isReady;")), 100, Settings.MaxWaitDocReady);
					Thread.Sleep(Settings.WaitAsyncs);
					Login(driver);
					Thread.Sleep(200);
					ClearBrowserData(driver);
					DbStorage.SetMessageRead(msgid);
					log.InfoFormat("Set item {0} read", msgid.ToString("N"));
				}, string.Format("Failed to process item {0}", msgid))));
			}
		}

		private static void Login(RemoteWebDriver driver)
		{
			driver.Navigate().GoToUrl(new Uri(Settings.BaseUri, "/login"));
			var loginField = driver.FindElementById("login");
			loginField.Clear();
			loginField.SendKeys(Settings.Login);
			var passwordField = driver.FindElementById("password");
			passwordField.Clear();
			passwordField.SendKeys(Settings.Pass);
			var form = driver.FindElementByClassName("form-signin");
			form.Submit();
		}

		private static void Check(RemoteWebDriver driver, Guid msgid)
		{
			driver.Navigate().GoToUrl(new Uri(Settings.BaseUri, "/msg?id=" + msgid.ToString("N")));
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