using System;
using System.Web;
using log4net;
using mssngrrr.utils;

namespace mssngrrr
{
	public abstract class BaseHandler : IHttpHandler
	{
		public void ProcessRequest(HttpContext context)
		{
			try
			{
				context.Response.ContentType = "text/plain; charset=utf-8";
				context.Response.AppendHeader("Cache-Control", "no-cache");

				var result = ProcessRequestInternal(context);
				context.Response.Write(result.ToJsonString());
			}
			catch(Exception e)
			{
				Log.Error(string.Format("Failed to process request '{0}'", context.Request.RawUrl), e);

				string message = null;
				var e1 = e as AjaxException;
				if(e1 != null)
					message = e1.Message;
				else
				{
					var e2 = e as HttpException;
					if(e2 != null && e2.WebEventCode == System.Web.Management.WebEventCodes.RuntimeErrorPostTooLarge)
						message = string.Format("Request too large (max {0}KB)", Settings.MaxRequestLength);
				}

				var result = new AjaxResult {Error = message ?? "Unknown server error"};
				context.Response.Write(result.ToJsonString());
			}
		}

		public bool IsReusable { get { return true; } }

		protected abstract AjaxResult ProcessRequestInternal(HttpContext context);

		private static readonly ILog Log = LogManager.GetLogger(typeof(BaseHandler));
	}
}