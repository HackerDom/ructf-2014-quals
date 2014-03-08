using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using log4net;
using mssngrrr.utils;

namespace mssngrrr
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

			var userId = GetOrSetUserId(context);
			context.Items.Add(UserIdParamName, userId.ToString("N"));

			var form = "N/A";
			var files = "N/A";

			try
			{
				form = TryGetFormToLog(context).SafeToLog();
				files = TryGetFilesToLog(context).SafeToLog();
			}
			finally
			{
				Log.InfoFormat("{0,-4} '{1}', form '{2}', files '{3}'",
					context.Request.HttpMethod,
					context.Request.RawUrl.SafeToLog(),
					form,
					files);
			}
		}

		private static Guid GetOrSetUserId(HttpContext context)
		{
			var userIdCookie = context.Request.Cookies[UserIdParamName];
			if(userIdCookie == null || userIdCookie.Value == null)
				return SetNewUserId(context);
			if(userIdCookie.Value.Length != 64)
				return SetNewUserId(context);
			Guid userId;
			if(!Guid.TryParseExact(userIdCookie.Value.Substring(0, 32), "N", out userId))
				return SetNewUserId(context);
			Guid hash;
			if(!Guid.TryParseExact(userIdCookie.Value.Substring(32, 32), "N", out hash))
				return SetNewUserId(context);
			using(var hmac = new HMACMD5(Settings.HmacKey))
			{
				if(hash != new Guid(hmac.ComputeHash(userId.ToByteArray())))
					return SetNewUserId(context);
			}
			return userId;
		}

		private static Guid SetNewUserId(HttpContext context)
		{
			using(var hmac = new HMACMD5(Settings.HmacKey))
			{
				var userId = Guid.NewGuid();
				var hash = new Guid(hmac.ComputeHash(userId.ToByteArray()));
				var value = userId.ToString("N") + hash.ToString("N");
				var cookie = new HttpCookie(UserIdParamName, value) {Expires = DateTime.UtcNow.AddDays(7)};
				context.Response.SetCookie(cookie);
				return userId;
			}
		}

		private static string TryGetFormToLog(HttpContext context)
		{
			return context.Request.Form.ToString();
		}

		private static string TryGetFilesToLog(HttpContext context)
		{
			return string.Join(",", GetFiles(context).Select(file => string.Format("{0}:{1}:{2}", file.FileName, file.ContentLength, file.ContentType)));
		}

		private static IEnumerable<HttpPostedFile> GetFiles(HttpContext context)
		{
			for(int i = 0; i < context.Request.Files.Count; i++)
				yield return context.Request.Files[i];
		}

		public static Guid GetUserId()
		{
			Guid userId;
			if(!Guid.TryParseExact(HttpContext.Current.Items[UserIdParamName] as string, "N", out userId))
				throw new Exception("UserId not found");
			return userId;
		}

		private const string UserIdParamName = "secureid";
		private static readonly ILog Log = LogManager.GetLogger(typeof(AuthModule));
	}
}