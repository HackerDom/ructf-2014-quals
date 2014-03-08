using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Threading;
using log4net;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.Remote;

namespace irrsatest
{
	internal class DriversPool : IDisposable
	{
		public DriversPool()
		{
			semaphore = new Semaphore(Settings.FirefoxProfiles.Length, Settings.FirefoxProfiles.Length);
			dict = new ConcurrentDictionary<RemoteWebDriver, bool>();
			foreach(string profile in Settings.FirefoxProfiles)
			{
				var driver = StartNewDriver(profile);
				dict[driver] = false;
			}
		}

		public void UsingDriver(Action<RemoteWebDriver> action)
		{
			semaphore.WaitOne();
			var driver = dict.FirstOrDefault(pair => dict.TryUpdate(pair.Key, true, false)).Key;
			try
			{
				using(ThreadContext.Stacks["driver"].Push(driver.GetHashCode().ToString("x8")))
					action(driver);
			}
			finally
			{
				dict[driver] = false;
				semaphore.Release();
			}
		}

		public void Dispose()
		{
			foreach(var driver in dict.Keys)
			{
				try
				{
					driver.Quit();
				}
				catch {}
				driver.Dispose();
			}
		}

		public int Count { get { return dict.Count; } }

		private RemoteWebDriver StartNewDriver(string profilePath)
		{
			var profile = new FirefoxProfile(profilePath);
			var driver = new FirefoxDriver(new FirefoxBinary(Settings.FirefoxPath), profile);
			driver.Manage().Timeouts().SetPageLoadTimeout(Settings.PageLoadTimeout);
			driver.Manage().Timeouts().SetScriptTimeout(Settings.ScriptTimeout);
			//driver.Manage().Window.Maximize();
			driver.Url = Settings.BaseUri.ToString();
			log.InfoFormat("Started WebDriver [{0}] with profile '{1}'", driver.GetHashCode(), profilePath);
			return driver;
		}

		private static readonly ILog log = LogManager.GetLogger(typeof(DriversPool));
		private readonly ConcurrentDictionary<RemoteWebDriver, bool> dict;
		private readonly Semaphore semaphore;
	}
}