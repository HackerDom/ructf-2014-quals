using System.IO;
using System.Web;
using log4net;
using mssngrrr.utils;

namespace mssngrrr
{
	public class SendCspReport : IHttpHandler
	{
		public void ProcessRequest(HttpContext context)
		{
			using(var reader = new StreamReader(context.Request.InputStream))
				Log.Info(reader.ReadToEnd().SafeToLog());
		}

		public bool IsReusable { get { return true; } }

		private static readonly ILog Log = LogManager.GetLogger(typeof(SendCspReport));
	}
}