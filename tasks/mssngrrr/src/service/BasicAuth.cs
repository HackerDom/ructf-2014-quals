using System;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using log4net;
using mssngrrr.utils;

namespace mssngrrr
{
	public class BasicAuth
	{
		public static void Auth(HttpContext context)
		{
			if(context.Request.UserHostAddress != null && Settings.LocalIPs.Contains(context.Request.UserHostAddress))
			{
				context.Items[LoginParamName] = CheckSystemLogin;
				return;
			}
			var auth = context.Request.Headers["Authorization"];
			if(auth != null)
			{
				var header = AuthenticationHeaderValue.Parse(auth);
				if(string.Equals(header.Scheme, "basic", StringComparison.InvariantCultureIgnoreCase) && header.Parameter != null)
				{
					var login = CheckAuthorization(header.Parameter);
					if(login != null)
					{
						context.Items[LoginParamName] = login;
						return;
					}
				}
			}
			context.Response.Headers.Add("WWW-Authenticate", string.Format("Basic realm=\"{0}\"", Realm));
			throw new HttpException(401, "Unauthorized");
		}

		public static string GetLogin()
		{
			var login = HttpContext.Current.Items[LoginParamName] as string;
			if(login == null)
				throw new Exception("Login not found");
			return login;
		}

		public static bool IsChecksystem()
		{
			return GetLogin() == CheckSystemLogin;
		}

		private static string CheckAuthorization(string auth)
		{
			try
			{
				var parts = Encoding.UTF8.GetString(Convert.FromBase64String(auth)).Split(new[] {':'}, 2);
				if(parts.Length != 2)
					return null;
				return CheckUserAndPass(parts[0], parts[1]);
			}
			catch(Exception e)
			{
				Log.Error(string.Format("Failed to authenticate '{0}'", auth.SafeToLog()), e);
				return null;
			}
		}

		private static string CheckUserAndPass(string login, string pass)
		{
			if(string.IsNullOrWhiteSpace(login))
				return null;
			var loginWithSalt = Settings.BasicAuthHashPrefix + login + Settings.BasicAuthHashSalt;
			using(var md5 = MD5.Create())
			{
				var hash = BitConverter.ToString(md5.ComputeHash(Encoding.UTF8.GetBytes(loginWithSalt))).Replace("-", string.Empty).ToLowerInvariant();
				return string.Equals(hash, pass, StringComparison.InvariantCultureIgnoreCase) ? login : null;
			}
		}

		private const string Realm = "mssngrrr";
		private const string LoginParamName = "login";
		private const string CheckSystemLogin = "CHECKSYSTEM";
		private static readonly ILog Log = LogManager.GetLogger(typeof(BasicAuth));
	}
}