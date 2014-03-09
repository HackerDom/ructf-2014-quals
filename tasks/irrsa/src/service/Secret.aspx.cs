using System.Web.UI;

namespace irrsa
{
	public partial class Secret : Page
	{
		protected override void OnLoad(System.EventArgs e)
		{
			var agent = AuthModule.FindAgentName();
			if(agent != null)
				FlagField.Visible = true;
			else
				Response.Redirect("/login?back=%2ftopsecret");
		}
	}
}