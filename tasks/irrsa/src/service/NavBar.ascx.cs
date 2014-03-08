using System;
using System.Web.UI;

namespace irrsa
{
	public partial class NavBar : UserControl
	{
		protected override void OnLoad(EventArgs e)
		{
			Agent = AuthModule.FindAgentName();

			LoggedOut.Visible = Agent == null;

			LoggedIn.Visible = Agent != null;
			RequestsLink.Visible = Agent != null;
		}

		protected string Agent;
	}
}