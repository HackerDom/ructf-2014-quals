using System.Web;

namespace irrsa
{
	public class Auth : BaseHandler
	{
		protected override AjaxResult ProcessRequestInternal(HttpContext context)
		{
			var login = context.Request.Form["login"];
			var pass = context.Request.Form["pass"];

			if(string.IsNullOrEmpty(login) || string.IsNullOrEmpty(pass) || !DbStorage.Auth(login, pass))
				throw new AjaxException("Invalid login/pass");

			var ssid = AuthModule.GetSsid();
			DbStorage.AddSessionId(login, ssid);
			AuthModule.UpdateAgentNameCache(login);

			return new AjaxResult {Message = "OK"};
		}
	}
}