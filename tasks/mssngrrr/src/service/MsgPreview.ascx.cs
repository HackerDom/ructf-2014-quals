using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;

namespace mssngrrr
{
	public partial class MsgPreview : UserControl
	{
		protected override void OnLoad(EventArgs e)
		{
			var userid = AuthModule.GetUserId();
			Item = DbStorage.FindMessageById(MsgId);
			if(Item == null || Item.To != userid)
				return;
			if(!string.IsNullOrEmpty(Item.Img))
			{
				ImgPath = ResolveClientUrl(Path.Combine(Path.Combine(Settings.UploadPath, Item.To.ToString("N")), Item.Img));
				Img.Visible = true;
			}
			ThemeFiles.Visible =
				!string.IsNullOrEmpty(Item.Theme) //NOTE: OMG! No theme validation here! :)
				&& !(BasicAuth.IsChecksystem() && Themes.Contains(Item.Theme)); //NOTE: And small hack to reduce CPU load for checksystem ;)
			Content.Visible = true;
		}

		public Guid MsgId;

		protected DbItem Item;
		protected string ImgPath;

		private static readonly HashSet<string> Themes = new HashSet<string> {"rainy", "winter"};
	}
}