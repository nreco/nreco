using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using NReco;
using NI.Data.Dalc;

namespace NReco.Web.Site.Data {

	/// <summary>
	/// Relation editor wrapper that writes to log relation changes
	/// </summary>
	public class LogRelationEditorWrapper : IRelationEditor {

		/// <summary>
		/// Underlying relation editor
		/// </summary>
		public IRelationEditor RelationEditor { get; set; }

		/// <summary>
		/// Get or set relation name
		/// </summary>
		public string RelationName { get; set; }
		
		/// <summary>
		/// Get or set write log operation
		/// </summary>
		public IOperation<LogContext> WriteLog { get; set; }

		public void Set(object fromKey, IEnumerable toKeys) {
			var oldToKeys = GetToKeys(fromKey);
			RelationEditor.Set(fromKey, toKeys);
			var logContext = new LogContext() {
				FromKey = fromKey,
				RelationName = RelationName,
				AddedToKeys = toKeys.Cast<object>().Where( toKey => !DalcRelationEditor.Contains(toKey, oldToKeys)).ToArray(),
				RemovedToKeys = oldToKeys.Cast<object>().Where(oldToKey => !DalcRelationEditor.Contains(oldToKey, toKeys)).ToArray()
			};
			WriteLog.Execute(logContext);
		}

		public object[] GetToKeys(object fromKey) {
			return RelationEditor.GetToKeys(fromKey);
		}
		
		public class LogContext {
			public object[] AddedToKeys { get; set; }
			public object[] RemovedToKeys { get; set; }
			public object FromKey { get; set; }
			public string RelationName { get; set; }
		}

	}
	
}
