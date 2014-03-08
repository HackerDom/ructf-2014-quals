using System;
using System.Diagnostics;
using System.Threading;
using log4net;

namespace irrsatest.utils
{
	internal class DoIt
	{
		public static void WithRetries(Action action, string errorMsg, int retries = 3, int timeout = 1000)
		{
			for(int i = 0; i < retries; i++)
			{
				try
				{
					action.Invoke();
					return;
				}
				catch(Exception e)
				{
					if(i == retries - 1)
						return;
					log.Error(errorMsg, e);
					Thread.Sleep(timeout * i);
				}
			}
		}

		public static T TryOrDefault<T>(Func<T> func)
		{
			try
			{
				return func();
			}
			catch
			{
				return default(T);
			}
		}

		public static void Wait(Func<bool> func, int iterationTimeout, int totalTimeout)
		{
			var watch = Stopwatch.StartNew();
			while(!func() && watch.ElapsedMilliseconds < totalTimeout)
				Thread.Sleep(iterationTimeout);
		}

		private static readonly ILog log = LogManager.GetLogger(typeof(DoIt));
	}
}