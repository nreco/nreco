using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.Web;
using System.Web.UI;
using NReco.Operations;

namespace NReco.Web.ActionHandlers {
	
	/// <summary>
	/// Control subtree embedded 'methods' action handler
	/// </summary>
	public class ControlTreeHandler : IProvider<ActionContext,IOperation<ActionContext>> {
		string _ExecuteMethodFormat = "Execute_{0}";
		string _ExecuteBeforeMethodFormat = "ExecuteBefore_{0}";
		string _ExecuteAfterMethodFormat = "ExecuteAfter_{0}";

		public string ExecuteMethodFormat {
			get { return _ExecuteMethodFormat; }
			set { _ExecuteMethodFormat = value; }
		}

		public string ExecuteBeforeMethodFormat {
			get { return _ExecuteBeforeMethodFormat; }
			set { _ExecuteBeforeMethodFormat = value; }
		}

		public string ExecuteAfterMethodFormat {
			get { return _ExecuteAfterMethodFormat; }
			set { _ExecuteAfterMethodFormat = value; }
		}

		public ControlTreeHandler() { }

		public IOperation<ActionContext> Provide(ActionContext context) {
			if (context.Origin != null && context.Args != null && context.CommandName != null) {
				List<IOperation<ActionContext>> list = new List<IOperation<ActionContext>>();
				FindControlOperations(list, context.Origin, String.Format(ExecuteBeforeMethodFormat, context.CommandName));
				FindControlOperations(list, context.Origin, String.Format(ExecuteMethodFormat, context.CommandName));
				FindControlOperations(list, context.Origin, String.Format(ExecuteAfterMethodFormat, context.CommandName));
				if (list.Count == 1)
					return list[0];
				if (list.Count > 1)
					return new Chain<ActionContext>(list.ToArray());
			}
			return null;
		}

		protected void FindControlOperations(IList<IOperation<ActionContext>> ops, Control ctrl, string methodName) {
			MethodInfo execMethodInfo = ctrl.GetType().GetMethod(
				methodName, 
				BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
			if (execMethodInfo != null) {
				ops.Add(new ControlOperation(ctrl, execMethodInfo));
			}
			foreach (Control child in ctrl.Controls)
				FindControlOperations(ops, child, methodName);
		}

		internal class ControlOperation : IOperation<ActionContext> {
			object Instance;
			MethodInfo ExecuteMethod;

			internal ControlOperation(object ctrl, MethodInfo m) {
				Instance = ctrl;
				ExecuteMethod = m;
			}

			public void Execute(ActionContext context) {
				ExecuteMethod.Invoke(Instance, new object[] { context });
			}
		}

	}

}
