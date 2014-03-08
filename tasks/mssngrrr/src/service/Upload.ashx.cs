using System;
using System.Drawing;
using System.IO;
using System.Web;
using log4net;

namespace mssngrrr
{
	public class Upload : BaseHandler
	{
		protected override AjaxResult ProcessRequestInternal(HttpContext context)
		{
			if(context.Request.Files.Count == 0)
				throw new AjaxException("No files uploaded");

			if(context.Request.Files.Count > 1)
				throw new AjaxException("Uploading multiple files not allowed");

			var uploadPath = context.Server.MapPath(Settings.UploadPath);
			Directory.CreateDirectory(uploadPath);

			var file = context.Request.Files[0];

			string filename;
			string extension;
			try
			{
				filename = Path.GetFileName(file.FileName);
				extension = Path.GetExtension(filename);
			}
			catch(ArgumentException e)
			{
				throw new AjaxException("Invalid filename", e);
			}

			if(string.IsNullOrEmpty(filename))
				throw new AjaxException("Invalid filename");

			if(file.ContentLength > Settings.MaxFileSize)
				throw new AjaxException(string.Format("File too large (max {0} bytes)", Settings.MaxFileSize));

			if(!(Settings.AllowedMimeTypes.Contains(file.ContentType) && Settings.AllowedExtensions.Contains(extension)))
				throw new AjaxException("File type not allowed");

			int width, height;

			try
			{
				using(var img = Image.FromStream(file.InputStream))
				{
					width = img.Width;
					height = img.Height;
				}
			}
			catch(Exception e)
			{
				throw new AjaxException("Failed to open image", e);
			}

			if(width > Settings.MaxImageWidth || height > Settings.MaxImageHeight)
				throw new AjaxException(string.Format("Image too large (max {0}x{1})", Settings.MaxImageWidth, Settings.MaxImageHeight));

			var userid = AuthModule.GetUserId();

			var dir = Path.Combine(uploadPath, userid.ToString("N"));
			Directory.CreateDirectory(dir);

			var filepath = Path.Combine(dir, filename);
			file.SaveAs(filepath);

			Log.InfoFormat("Saved image '{0}'", filepath);

			return new AjaxResult {Name = filename, Length = file.ContentLength};
		}

		private static readonly ILog Log = LogManager.GetLogger(typeof(Upload));
	}
}