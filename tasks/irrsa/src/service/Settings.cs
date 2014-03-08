using System;
using System.Collections.Generic;
using System.Configuration;
using System.Threading;
using log4net;

namespace irrsa
{
	public static class Settings
	{
		static Settings()
		{
			TryUpdate();
			updateThread = new Thread(() =>
			{
				TryUpdate();
				Thread.Sleep(30000);
			}) {IsBackground = true};
			updateThread.Start();
		}

		public static ConnectionStringSettings ConnectionString { get; private set; }

		public static byte[] HmacKey { get; private set; }
		public static string BasicAuthHashPrefix { get; private set; }
		public static string BasicAuthHashSalt { get; private set; }
		public static HashSet<string> LocalIPs { get; private set; }

		public static int MaxEmailLength { get; private set; }
		public static int MaxPhoneLength { get; private set; }
		public static int MaxMessageLength { get; private set; }
		public static int MaxUserAgentLength { get; private set; }

		public static int DelayBeforeNextMessageSec { get; private set; }

		public static string Flag { get; private set; }

		private static void TryUpdate()
		{
			try
			{
				ConnectionString = ConfigurationManager.ConnectionStrings["main"];
				HmacKey = Convert.FromBase64String(ConfigurationManager.AppSettings["HmacKey"]);
				BasicAuthHashPrefix = ConfigurationManager.AppSettings["BasicAuthHashPrefix"];
				BasicAuthHashSalt = ConfigurationManager.AppSettings["BasicAuthHashSalt"];
				LocalIPs = new HashSet<string>(ConfigurationManager.AppSettings["LocalIPs"].Split('|'));
				MaxEmailLength = int.Parse(ConfigurationManager.AppSettings["MaxEmailLength"]);
				MaxPhoneLength = int.Parse(ConfigurationManager.AppSettings["MaxPhoneLength"]);
				MaxMessageLength = int.Parse(ConfigurationManager.AppSettings["MaxMessageLength"]);
				MaxUserAgentLength = int.Parse(ConfigurationManager.AppSettings["MaxUserAgentLength"]);
				DelayBeforeNextMessageSec = int.Parse(ConfigurationManager.AppSettings["DelayBeforeNextMessageSec"]);
				Flag = ConfigurationManager.AppSettings["Flag"];
			}
			catch(Exception e)
			{
				Log.Error("Failed to update settings", e);
			}
		}


		private static readonly ILog Log = LogManager.GetLogger(typeof(Settings));
		private static readonly Thread updateThread;
	}
}