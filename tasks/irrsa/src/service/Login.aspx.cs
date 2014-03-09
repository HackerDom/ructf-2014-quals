using System;
using System.Web.UI;

namespace irrsa
{
	public partial class Login : Page
	{
		protected override void OnLoad(EventArgs e)
		{
			/*if(Context.Request.QueryString["logout"] != null)
			{
				var ssid = AuthModule.GetSsid();
				DbStorage.RemoveSessionId(ssid);
				AuthModule.UpdateAgentNameCache(null);
				Response.Redirect("/", true);
			}*/
		}
	}
}