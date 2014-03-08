using System;
using log4net;
using log4net.Config;

namespace mssngrrrtest
{
	internal class Program
	{
		private static void Main()
		{
			XmlConfigurator.Configure();
			try
			{
				using(var driversPool = new DriversPool())
				{
					var checker = new Checker(driversPool);
					checker.RunLoop();
				}
			}
			catch(Exception e)
			{
				Log.Fatal(e);
			}
		}

		private static readonly ILog Log = LogManager.GetLogger(typeof(Program));
	}
}