using System;
using System.Collections.Concurrent;

namespace irrsa
{
	public static class Limit
	{
		public static bool TryUpdate(string login, string type, int seconds)
		{
			var utcNow = DateTime.UtcNow;
			return utcNow == limits.AddOrUpdate(login + "@" + type, utcNow, (key, time) => time > utcNow.AddSeconds(-seconds) ? time : utcNow);
		}

		private static readonly ConcurrentDictionary<string, DateTime> limits = new ConcurrentDictionary<string, DateTime>();
	}
}