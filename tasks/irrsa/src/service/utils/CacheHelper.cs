using System;
using System.Web;
using System.Web.Caching;

namespace irrsa.utils
{
	public static class CacheHelper
	{
		public static void UpdateCacheItem<T>(string key, Func<T> get, int secondsToLive = 60, CacheItemPriority priority = CacheItemPriority.Default)
			where T : class
		{
			CacheItem(key, get.Invoke() ?? NullObject, priority, secondsToLive);
		}

		public static T FindAndCacheItem<T>(string key, Func<T> get, int secondsToLive = 60, CacheItemPriority priority = CacheItemPriority.Default)
			where T : class
		{
			var obj = HttpContext.Current.Cache[key];
			if(ReferenceEquals(obj, NullObject))
				return null;
			var item = obj as T;
			if(item != null)
				return item;
			CacheItem(key, (item = get.Invoke()) ?? NullObject, priority, secondsToLive);
			return item;
		}

		private static void CacheItem(string key, object value, CacheItemPriority priority, int secondsToLive)
		{
			HttpContext.Current.Cache.Insert(key, value, null, DateTime.UtcNow.AddSeconds(secondsToLive), Cache.NoSlidingExpiration, priority, null);
		}

		private static readonly object NullObject = new object();
	}
}