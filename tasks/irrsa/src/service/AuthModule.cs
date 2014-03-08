using System;
using System.Security.Cryptography;
using System.Web;
using log4net;
using irrsa.utils;

namespace irrsa
{
	public class AuthModule : IHttpModule
	{
		public void Dispose()
		{
		}

		public void Init(HttpApplication context)
		{
			context.AuthenticateRequest += OnAuth;
			context.PreRequestHandlerExecute += OnPreRequest;
		}

		private static void OnAuth(object sender, EventArgs e)
		{
			BasicAuth.Auth(((HttpApplication)sender).Context);
		}

		private static void OnPreRequest(object sender, EventArgs e)
		{
			var app = (HttpApplication)sender;
			var context = app.Context;

			var ssid = GetOrSetSsid(context);
			context.Items.Add(SsidParamName, ssid.ToString("N"));

			Log.InfoFormat("{0,-4} '{1}', form '{2}', ua '{3}'", context.Request.HttpMethod, context.Request.RawUrl, context.Request.Form, context.Request.UserAgent);
		}

		private static Guid GetOrSetSsid(HttpContext context)
		{
			var ssidCookie = context.Request.Cookies[SsidParamName];
			if(ssidCookie == null || ssidCookie.Value == null)
				return SetNewSsid(context);
			if(ssidCookie.Value.Length != 64)
				return SetNewSsid(context);
			Guid ssid;
			if(!Guid.TryParseExact(ssidCookie.Value.Substring(0, 32), "N", out ssid))
				return SetNewSsid(context);
			Guid hash;
			if(!Guid.TryParseExact(ssidCookie.Value.Substring(32, 32), "N", out hash))
				return SetNewSsid(context);
			using(var hmac = new HMACMD5(Settings.HmacKey))
			{
				if(hash != new Guid(hmac.ComputeHash(ssid.ToByteArray())))
					return SetNewSsid(context);
			}
			return ssid;
		}

		private static Guid SetNewSsid(HttpContext context)
		{
			using(var hmac = new HMACMD5(Settings.HmacKey))
			{
				var ssid = Guid.NewGuid();
				var hash = new Guid(hmac.ComputeHash(ssid.ToByteArray()));
				var value = ssid.ToString("N") + hash.ToString("N");
				var cookie = new HttpCookie(SsidParamName, value) {Expires = DateTime.UtcNow.AddDays(7), HttpOnly = true};
				context.Response.SetCookie(cookie);
				return ssid;
			}
		}

		public static Guid GetSsid()
		{
			Guid userId;
			if(!Guid.TryParseExact(HttpContext.Current.Items[SsidParamName] as string, "N", out userId))
				throw new Exception("ssid not found");
			return userId;
		}

		public static string FindAgentName()
		{
			var ssid = GetSsid();
			return CacheHelper.FindAndCacheItem(ssid.ToString("N"), () => DbStorage.FindLogin(ssid));
		}

		public static void UpdateAgentNameCache(string agent)
		{
			var ssid = GetSsid();
			CacheHelper.UpdateCacheItem(ssid.ToString("N"), () => agent);
		}

		private const string SsidParamName = "ssid";
		private static readonly ILog Log = LogManager.GetLogger(typeof(AuthModule));
	}
}