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
			dict = new ConcurrentDictionary<DriverInfo, bool>();
			foreach(string profile in Settings.FirefoxProfiles)
			{
				var driverInfo = new DriverInfo {Driver = StartNewDriver(profile), ProfilePath = profile, AcquireCount = 0};
				dict[driverInfo] = false;
			}
		}

		public void UsingDriver(Action<RemoteWebDriver> action)
		{
			semaphore.WaitOne();
			var driverInfo = dict.FirstOrDefault(pair => dict.TryUpdate(pair.Key, true, false)).Key;
			try
			{
				using(ThreadContext.Stacks["driver"].Push(driverInfo.Driver.GetHashCode().ToString("x8")))
					action(driverInfo.Driver);
			}
			finally
			{
				if(++driverInfo.AcquireCount >= Settings.ItemsBeforeReinitializeDrivers && Settings.ItemsBeforeReinitializeDrivers != 0)
				{
					var oldDriver = driverInfo.Driver;
					log.InfoFormat("Driver acquired {0} times - restarting", driverInfo.AcquireCount);
					try
					{
						driverInfo.Driver = StartNewDriver(driverInfo.ProfilePath);
						QuitAndDispose(oldDriver);
						driverInfo.AcquireCount = 0;
					}
					catch(Exception e)
					{
						log.Error("Failed to restart driver", e);
					}
				}
				dict[driverInfo] = false;
				semaphore.Release();
			}
		}

		public void Dispose()
		{
			foreach(var driverInfo in dict.Keys)
			{
				QuitAndDispose(driverInfo.Driver);
			}
		}

		private void QuitAndDispose(RemoteWebDriver driver)
		{
			try
			{
				driver.Quit();
			}
			catch {}
			driver.Dispose();
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

		private class DriverInfo
		{
			public RemoteWebDriver Driver;
			public string ProfilePath;
			public int AcquireCount;
		}

		private static readonly ILog log = LogManager.GetLogger(typeof(DriversPool));
		private readonly ConcurrentDictionary<DriverInfo, bool> dict;
		private readonly Semaphore semaphore;
	}
}