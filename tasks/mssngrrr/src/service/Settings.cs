using System;
using System.Collections.Generic;
using System.Configuration;
using System.Threading;
using System.Web.Configuration;
using log4net;

namespace mssngrrr
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

		public static string BasicAuthHashPrefix { get; private set; }
		public static string BasicAuthHashSalt { get; private set; }
		public static byte[] HmacKey { get; private set; }
		public static Guid Admin { get; private set; }
		public static HashSet<string> LocalIPs { get; private set; }

		public static string UploadPath { get; private set; }
		public static int MaxFileSize { get; private set; }

		public static int MaxImageWidth { get; private set; }
		public static int MaxImageHeight { get; private set; }

		public static HashSet<string> AllowedExtensions { get; private set; }
		public static HashSet<string> AllowedMimeTypes { get; private set; }

		public static int MaxSubjectLength { get; private set; }
		public static int MaxMessageLength { get; private set; }
		public static int MaxImageFilenameLength { get; private set; }
		public static int DelayBeforeNextMessageToAdminSec { get; private set; }
		public static int DelayBeforeNextMessageToUserSec { get; private set; }

		public static int MaxRequestLength { get; private set; }

		private static void TryUpdate()
		{
			try
			{
				ConnectionString = ConfigurationManager.ConnectionStrings["main"];
				BasicAuthHashPrefix = ConfigurationManager.AppSettings["BasicAuthHashPrefix"];
				BasicAuthHashSalt = ConfigurationManager.AppSettings["BasicAuthHashSalt"];
				HmacKey = Convert.FromBase64String(ConfigurationManager.AppSettings["HmacKey"]);
				Admin = Guid.Parse(ConfigurationManager.AppSettings["Admin"]);
				LocalIPs = new HashSet<string>(ConfigurationManager.AppSettings["LocalIPs"].Split('|'));
				UploadPath = ConfigurationManager.AppSettings["UploadPath"];
				MaxFileSize = int.Parse(ConfigurationManager.AppSettings["MaxFileSize"]);
				MaxImageWidth = int.Parse(ConfigurationManager.AppSettings["MaxImageWidth"]);
				MaxImageHeight = int.Parse(ConfigurationManager.AppSettings["MaxImageHeight"]);
				AllowedExtensions = new HashSet<string>(ConfigurationManager.AppSettings["AllowedExtensions"].Split('|'), StringComparer.InvariantCultureIgnoreCase);
				AllowedMimeTypes = new HashSet<string>(ConfigurationManager.AppSettings["AllowedMimeTypes"].Split('|'), StringComparer.InvariantCultureIgnoreCase);
				MaxSubjectLength = int.Parse(ConfigurationManager.AppSettings["MaxSubjectLength"]);
				MaxMessageLength = int.Parse(ConfigurationManager.AppSettings["MaxMessageLength"]);
				MaxImageFilenameLength = int.Parse(ConfigurationManager.AppSettings["MaxImageFilenameLength"]);
				DelayBeforeNextMessageToAdminSec = int.Parse(ConfigurationManager.AppSettings["DelayBeforeNextMessageToAdminSec"]);
				DelayBeforeNextMessageToUserSec = int.Parse(ConfigurationManager.AppSettings["DelayBeforeNextMessageToUserSec"]);
				MaxRequestLength = ((HttpRuntimeSection)ConfigurationManager.GetSection("system.web/httpRuntime")).MaxRequestLength;
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