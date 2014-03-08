namespace mssngrrr.utils
{
	public static class Log4NetExtension
	{
		public static string SafeToLog(this string line)
		{
			return line.Trim().Replace("\r", "\\r").Replace("\n", "\\n");
		}
	}
}