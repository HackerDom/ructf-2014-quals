using System;
using System.Net;
using System.Web;
using log4net;

namespace mssngrrr
{
	public class Global : HttpApplication
	{
		static Global()
		{
			Log = LogManager.GetLogger(typeof(Global));
		}

		protected void Application_Start(object sender, EventArgs e)
		{
		}

		protected void Application_BeginRequest(object sender, EventArgs e)
		{
			Response.Headers.Remove("Server");
			Response.AddHeader("X-Frame-Options", "SAMEORIGIN");
			Response.AddHeader("X-XSS-Protection", "1; mode=block");
			Response.AddHeader("X-Content-Type-Options", "nosniff");
			Response.AddHeader("Content-Security-Policy", "script-src 'self' 'unsafe-inline' code.jquery.com netdna.bootstrapcdn.com;object-src 'none';media-src 'none';img-src 'self';frame-src 'self';style-src 'self' 'unsafe-inline' netdna.bootstrapcdn.com;font-src netdna.bootstrapcdn.com;report-uri /csp");
			Context.Items["context"] = Context.GetHashCode().ToString("x8");
		}

		protected void Application_Error(object sender, EventArgs e)
		{
			try
			{
				if(Context.CurrentHandler is BaseHandler) //NOTE: Exception will be catched by Handler
					return;

				var error = Server.GetLastError();
				Log.Error(error);

				try
				{
					Response.ClearContent();
					var httpError = error as HttpException;
					Response.StatusCode = httpError == null ? (int)HttpStatusCode.InternalServerError : httpError.GetHttpCode();
				}
				catch {}
			}
			catch(Exception exception)
			{
				Log.Error(exception);
			}
			finally
			{
				Server.ClearError();
			}
		}

		private static readonly ILog Log;
	}
}