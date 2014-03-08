using System;

namespace irrsa
{
	internal class AjaxException : Exception
	{
		public AjaxException(string message)
			: base(message)
		{
		}

		public AjaxException(string message, Exception innerException)
			: base(message, innerException)
		{
		}
	}
}