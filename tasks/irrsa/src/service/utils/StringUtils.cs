using System;
using System.Text;

namespace irrsa.utils
{
	public static class StringUtils
	{
		public static string Shorten(this string val, int min, int max = 0)
		{
			if(string.IsNullOrEmpty(val) || val.Length <= Math.Max(min, max))
				return val;
			var len = 0;
			var sb = new StringBuilder();
			foreach(var word in val.Split(' '))
			{
				if((len += word.Length + 1) > min)
				{
					if(sb.Length == 0)
						sb.Append(word.Substring(0, min));
					break;
				}
				sb.Append(' ');
				sb.Append(word);
			}
			return sb.ToString().TrimStart().TrimEnd(',') + "...";
		}

		public static string SubstringSafe(this string val, int offset, int length)
		{
			if(val == null || offset > val.Length)
				return null;
			return val.Substring(offset, Math.Min(length, val.Length - offset));
		}
	}
}