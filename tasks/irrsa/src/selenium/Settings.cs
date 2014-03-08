using System;
using System.Configuration;

namespace irrsatest
{
	internal static class Settings
	{
		public static ConnectionStringSettings ConnectionString { get { return ConfigurationManager.ConnectionStrings["main"]; } }

		public static string[] FirefoxProfiles { get { return ConfigurationManager.AppSettings["FirefoxProfiles"].Split(';'); } }
		public static string FirefoxPath { get { return ConfigurationManager.AppSettings["FirefoxPath"]; } }

		public static Uri BaseUri { get { return new Uri(ConfigurationManager.AppSettings["BaseUrl"]); } }

		public static TimeSpan PageLoadTimeout { get { return TimeSpan.FromSeconds(int.Parse(ConfigurationManager.AppSettings["PageLoadTimeoutSec"])); } }
		public static TimeSpan ScriptTimeout { get { return TimeSpan.FromSeconds(int.Parse(ConfigurationManager.AppSettings["ScriptTimeoutSec"])); } }

		public static int MaxWaitDocReady { get { return int.Parse(ConfigurationManager.AppSettings["MaxWaitDocReadySec"]) * 1000; } }
		public static int WaitAsyncs { get { return int.Parse(ConfigurationManager.AppSettings["WaitAsyncsSec"]) * 1000; } }

		public static string Login { get { return ConfigurationManager.AppSettings["Login"]; } }
		public static string Pass { get { return ConfigurationManager.AppSettings["Pass"]; } }
	}
}