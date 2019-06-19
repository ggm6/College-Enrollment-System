<html>
<body>
	<script type="text/javascript">

	function goBack() {
		window.history.back();
	}

	function close() {
		self.close();
	}

	</script>
	<%@page import="java.sql.*"%>
	<%


	try {

		String scheduleType=new String(request.getParameter("task"));
		scheduleType=scheduleType.substring(0,scheduleType.indexOf("-"));


		if (scheduleType.contains("regEnroll")) {

			String id=new String(request.getParameter("courseID3"));
			id = id.replaceAll("\\s","");
			String user=new String(request.getParameter("task"));
			user=user.substring(user.indexOf("-")+1);

			Connection db;
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			db= DriverManager.getConnection("jdbc:mysql://localhost:3306/scheduling","root","discipline");
			Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_READ_ONLY);

			String query=new String("SELECT * FROM " + user);
			ResultSet rs=stmt.executeQuery(query);
			while (rs.next()) {
				if (id.equals(rs.getString(1))) {
					out.println("<h3>Error: you are already enrolled in this course! (page no longer active)</h3><br>");
					out.println("<br><button onclick='goBack()'>Back</button>");
					return;
				}
			}

			query="SELECT * FROM Courses WHERE course_id=";
			if (!id.equals(""))
				query += id;
			else {
				out.println("<h3>Please select a real course ID.  (page no longer active)</h3><br>");
				out.println("<button onclick='goBack()'>Back</button>");
				return;
			}
			rs=stmt.executeQuery(query);
			if (!rs.next()) {
				out.println("<h3>Your search yielded no results. (page no longer active)</h3><br>");
				out.println("<br><button onclick='goBack()'>Back</button>");
				return;
			}

			rs.beforeFirst();
			rs.next();
			int num_fields = rs.getMetaData().getColumnCount();
			String fields[]=new String[num_fields];
			for (int i=0; i<num_fields; ++i)
			{
				fields[i]=rs.getString(i+1);
			}

			query="INSERT INTO " + user + " values (";
			for (int i=0; i<num_fields; ++i)
			{
				int index=fields[i].indexOf('\'');
				if (index!=-1) {
					fields[i]=new StringBuilder(fields[i]).insert(index,"\\").toString();
				}
				if (i==0)
					query += fields[i];
				else
					query += ",'" + fields[i] + "'";
			}
			query += ")";


			stmt.executeUpdate(query);
			out.println("<h3>Class Added Successfully!</h3><br>");
			out.println("<h3>Your Schedule:</h3><br>");
			query="SELECT * FROM " + user;
			rs=stmt.executeQuery(query);
			num_fields = rs.getMetaData().getColumnCount();
			out.println("<table border='1' style='width:50%'>");
			out.println("<tr align = 'center'><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>");
			while (rs.next()) {
				out.println("<tr>");
				for (int i=0; i<num_fields; ++i)
				{
					out.println("<td align = 'center'>");
					out.println(rs.getString(i+1));
					out.println("</td>");
				}
				out.println("</tr>");
			}
			out.println("</table><br><br>");
			out.println("<br><button onclick='goBack()'>Back</button>");

			rs.close();
			stmt.close();
			db.close();
		}

		else if (scheduleType.contains("smartEnroll")) {
			String user = new String(request.getParameter("task"));
			String ids = new String(user.substring(user.indexOf("-")+1,user.indexOf("*")));
			user = user.substring(user.indexOf("*")+1);
			String[] IDs = ids.split(",");
			for (int i=0; i<IDs.length; ++i) {
				IDs[i]=IDs[i].trim();
			}

			Connection db;
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			db= DriverManager.getConnection("jdbc:mysql://localhost:3306/scheduling","root","discipline");
			Statement stmt = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_READ_ONLY);

			String query=new String("SELECT * FROM " + user);
			ResultSet rs=stmt.executeQuery(query);
			for (int i=0; i<IDs.length; ++i) {
				boolean flag=false;
				while (rs.next()) {
					if (IDs[i].equals(rs.getString(1).trim())) {
						flag=true;
						break;
					}
				}
				if (flag==true) {
					out.println("<h4>You are already enrolled in " + IDs[i] + "!</h4><br>");
					IDs[i]="-1";
				}
				else
					out.println("<h4>" + IDs[i] + " added successfully!</h4><br>");
				rs.beforeFirst();
			}

			query="SELECT * FROM Courses WHERE course_id=";
			int pos=0;
			boolean flagger=false;
			for (int i=0; i<IDs.length; ++i) {
				if (IDs[i]!="-1") {
					flagger=true;
					query += IDs[i];
					pos=i;
					break;
				}
			}
			for (int i=pos+1; i<IDs.length; ++i) {
				if (IDs[i]!="-1") {
					if (i<IDs.length)
						query += " OR course_id=" + IDs[i];
				}
			}


			int num_fields;
			if (flagger==true) {
				rs=stmt.executeQuery(query);
				num_fields = rs.getMetaData().getColumnCount();
				String fields[]=new String[num_fields];

				while (rs.next()) {
					Statement statement = db.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_READ_ONLY);
					for (int i=0; i<num_fields; ++i)
					{
						fields[i]=rs.getString(i+1);
					}

					query="INSERT INTO " + user + " values (";
					for (int i=0; i<num_fields; ++i)
					{
						int index=fields[i].indexOf('\'');
						if (index!=-1) {
							fields[i]=new StringBuilder(fields[i]).insert(index,"\\").toString();
						}
						if (i==0)
							query += fields[i];
						else
							query += ",'" + fields[i] + "'";
					}
					query += ")";
					statement.executeUpdate(query);
				}
			}

			out.println("<h3>Your Schedule:</h3><br>");
			query="SELECT * FROM " + user;
			rs=stmt.executeQuery(query);
			num_fields = rs.getMetaData().getColumnCount();
			out.println("<table border='1' style='width:50%'>");
			out.println("<tr align = 'center'><th>Course ID</th><th>Course Name</th><th>Department</th><th>Professor</th><th>Time Slot</th></tr>");
			while (rs.next()) {
				out.println("<tr>");
				for (int i=0; i<num_fields; ++i)
				{
					out.println("<td align = 'center'>");
					out.println(rs.getString(i+1));
					out.println("</td>");
				}
				out.println("</tr>");
			}
			out.println("</table><br><br>");
			out.println("<br><button onclick='goBack()'>Back</button>");

			rs.close();
			stmt.close();
			db.close();


		}
	}

	catch (Exception e) {
		out.println(e.toString());  // Error message to display
	}

	%>
</body>
</html>