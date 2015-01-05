<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>

<%@ page contentType="text/html; charset=utf-8" %>
<%@ include file="checkLogStatus.jsp"%>
<% 
//获取参数
int itemPerPage=4;
String pageIndex=(String)request.getParameter("pageIndex");
String pageTotle=null;
pageTotle=request.getParameter("pageTotle");
//表示第一次进入当前结果，计算总页数
if(pageIndex==null)pageIndex="0";
String userID=(String)session.getAttribute("userID");
String attachPara="";

Connection con;
Statement stmt;
ResultSet rs;

Context ctx= new InitialContext();
DataSource ds =(DataSource)ctx.lookup("java:comp/env/jdbc/shopDB");
con=ds.getConnection();
stmt = con.createStatement();

request.setAttribute("title","Shopping Cart");
%>

<%@ include file="header.jsp"%>

<%
//如果是第一次进入，计算总页数
int nTotle=0;
if(pageIndex.equals("0")){
	//获取个数
	rs=stmt.executeQuery("select count(scID) from shop_cart where uID='"+userID+"'");

	//计算页数
	rs.first();
	nTotle=rs.getInt(1);
	if(nTotle==0){
		out.print("<h2 align='center'>您的购物车中还没有商品</h2>");
	}
	pageIndex="1";
	int pageSize=nTotle/itemPerPage+(nTotle%itemPerPage==0?0:1);
	pageTotle=Integer.toString(pageSize);
}

out.print("<h2 align='center'>购物车<small><em>共 "+nTotle+" 件商品， "+pageTotle+" 页</em></small></h2>");

int beginWith=itemPerPage*(Integer.parseInt(pageIndex)-1);
//获取结果
rs=stmt.executeQuery("select shop_cart.itemID,shop_cart.quantity,item.itemName,item.price,item.itemImage from shop_cart,item where shop_cart.uID='"+userID+"' and shop_cart.itemID = item.itemID order by scID limit "+Integer.toString(beginWith)+","+Integer.toString(itemPerPage));
%>
<div class='bs-callout col-md-9'>
	<table class="table table-hover">
		<thead>
			<th></th>
			<th>商品名</th>
			<th>价格</th>
			<th>数量</th>
		</thead>
		<tbody>
		<%
		int totlePrice=0;
		while(rs.next()){
			int quantity=rs.getInt(2);
			int price=rs.getInt(4);
			totlePrice+=quantity*price;
		%>

			<tr>
				<td><img width='120' height='120' src='<%=rs.getString(5)%>'/></td>
				<td><h5><%=rs.getString(3)%></h5></td>
				<td><h5>¥<%=rs.getString(4)%></h5></td>
				<td>
					<form method="post" class="form-inline" role="form" action='cartManager.jsp'>
					  <h5><%=rs.getString(2)%></h5>
					  <div class="form-group">
						<label class="sr-only" for="inputChangeNumber">change number</label>
						<input type="text" class="form-control" id="inputChangeNumber" placeholder="输入修改数量" name="changeTo"/>
						<input type="hidden" name="operation" value="1">
						<input type="hidden" name="itemID" value='<%=rs.getString(1)%>'>
					  </div>
					  <button type="submit" class="btn btn-default">submit</button>
					</form>
					<a href="cartManager.jsp?itemID=<%=rs.getString(1)%>&operation=2">删除</a>
				</td>
			</tr>

			<%
			}
			%>

		</tbody>

	</table>
		

</div>
<div class='col-md-3'>
	<h4>订单总金额：</h4>
	<h4>¥<%=totlePrice%></h4>
	<a href='orderManager.jsp?operation=0'><button type='button' class='btn btn-primary'>提交订单</button></a>
	<a href='showItem.jsp'><button type='button' class='btn btn-primary'>继续购物</button></a>
</div>

<%
rs.close();
stmt.close();
con.close();
String pageURL="showCart.jsp";
%>
<%@ include file="pages.jsp"%>


<%@ include file="footer.jsp"%>

