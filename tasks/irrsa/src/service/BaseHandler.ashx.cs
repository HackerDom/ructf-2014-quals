using System;
using System.Web;
using log4net;
using irrsa.utils;

namespace irrsa
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
				Log.Error(e);
				var e2 = e as AjaxException;
				var result = new AjaxResult {Error = (e2 != null ? e2.Message : null) ?? "Unknown server error"};
				context.Response.Write(result.ToJsonString());
			}
		}

		public bool IsReusable { get { return true; } }

		protected abstract AjaxResult ProcessRequestInternal(HttpContext context);

		private static readonly ILog Log = LogManager.GetLogger(typeof(BaseHandler));
	}
}