using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using System.ComponentModel;
using System.Linq.Dynamic;
using System.Linq.Expressions;

namespace NReco.LinqDynamic {
	
	public class EvalDynamic {
		public bool CacheEnabled { get; set; }
		
		/// <summary>
		/// Determines whether passed context is be exposed as dynamic expression parameters.
		/// </summary>
		/// <remarks>If false whole context is passed as one parameter with name 'var'</remarks>
		public bool ExposeVars { get; set; }

		static IDictionary<ExpressionCacheKey, Delegate> Cache = new Dictionary<ExpressionCacheKey, Delegate>();
		readonly string VarParamName = "var";

		public EvalDynamic() {
			CacheEnabled = true;
			ExposeVars = false;
		}

		public object Eval(string code, IDictionary<string, object> vars) {
			var paramsList = new List<ParameterExpression>();
			var valuesList = new List<object>();
			if (ExposeVars) {
				foreach (var varEntry in vars) {
					paramsList.Add(Expression.Parameter(varEntry.Value != null ? varEntry.Value.GetType() : typeof(object), varEntry.Key));
					valuesList.Add(varEntry.Value);
				}
			} else {
				paramsList.Add(Expression.Parameter(typeof(IDictionary<string,object>), VarParamName));
				valuesList.Add( vars );
			}
			Delegate compiledExpr;
			// check in cache
			ExpressionCacheKey cacheKey = new ExpressionCacheKey(code, paramsList.ToArray());
			if (!CacheEnabled || !Cache.TryGetValue(cacheKey, out compiledExpr)) {
				var expression = DynamicExpression.ParseLambda(paramsList.ToArray(), typeof(object), code, null);
				compiledExpr = expression.Compile();
				if (CacheEnabled)
					Cache[cacheKey] = compiledExpr;
			}
			return compiledExpr.DynamicInvoke(valuesList.ToArray());

		}

		protected internal class ExpressionCacheKey {
			string Code;
			ParameterExpression[] Params;
			int HashCode;

			public ExpressionCacheKey(string code, ParameterExpression[] prms) {
				Code = code;
				Params = prms;
				Array.Sort<ParameterExpression>(Params,
					delegate(ParameterExpression a, ParameterExpression b) { return a.Name.CompareTo(b.Name); });
				var sb = new StringBuilder();
				sb.Append(Code);
				for (int i=0; i<Params.Length; i++) {
					sb.Append('\0');
					sb.Append(Params[i].Name);
					sb.Append('\0');
					sb.Append(Params[i].Type.FullName);
				}
				HashCode = sb.ToString().GetHashCode();
			}

			public override bool Equals(object obj) {
				ExpressionCacheKey key = (ExpressionCacheKey)obj;
				if (Code != key.Code)
					return false;
				if (Params.Length != key.Params.Length)
					return false;
				for (int i = 0; i < Params.Length; i++)
					if (Params[i].Name != key.Params[i].Name ||
						Params[i].Type != key.Params[i].Type)
						return false;
				return true;
			}

			public override int GetHashCode() {
				return HashCode;
			}
		}


	}
}
