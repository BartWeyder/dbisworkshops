"""
Тут написати умову до завдання
Робота із сутностями Post та User
"""



"""
Routes and views for the flask application.
"""

from datetime import datetime
from flask import render_template, request, redirect
from FlaskWebProject1 import app

Post = {
	"PID" : 1,
	"PHONE" : "+380672670180",
	"POSTTITLE" : "iCAQIJyzlJaOvsM",
	"POSTTEXT" : "sdABLJOQmLZJXDoGbxYsvPAySFwkjYSvjPrKnfgGucKoMxFbjhSKLtLKjxlvihLWbRUKjUNWajgIMGaCnPuvSdGSMdGVMsdVtezv",
	"PUBLISHED" : 1,
	"POSTCREATEDTIME" : "04-NOV-18",
	"CATEGORYTITLE" : "NLihXJ"
	}

User = {
	"PHONE" : "+380672670180",
	"ROLENAME" : "Ynbkja",
	"NAME" : "NgxiLtmXmt",
	"EMAIL" : "xmntda@abc.com",
	"USERCREATEDTIME" : "04-NOV-18"
	}

@app.route('/')
@app.route('/home')
def home():
    """Renders the home page."""
    return render_template(
        'index.html',
        title='Home Page',
        year=datetime.now().year,
    )

@app.route('/contact')
def contact():
	"""Renders the contact page."""
	#return render_template(
	#    'contact.html',
	#    title='Contact',
	#    year=datetime.now().year,
	#    message='Your contact page.'
	#)
	return User["NAME"]

@app.route('/about')
def about():
	"""Renders the about page."""
	#return render_template(
	#    'about.html',
	#    title='About',
	#    year=datetime.now().year,
	#    message='Your application description page.'
	User["NAME"] = "Name";
	return User["NAME"]
	#)

@app.route('/api/<action>', methods = ['POST', 'GET'])
def api(action):
	if request.method == 'GET':
		if action == 'user':
			return render_template(
				'userform.html',
				U=User
			)
		elif action == 'post':
			return render_template(
				'postform.html',
				U=Post
			)
		elif action == 'all':
			return render_template(
				'all.html',
				U=User,
				P=Post
			)
		else:
			return render_template('404.html', a=action, availble=['user', 'post', 'all']), 404

	if request.method == 'POST':
		if action == 'user':
			User['PHONE'] = request.form['phone']
			User['ROLENAME'] = request.form['rolename']
			User['NAME'] = request.form['name']
			User['EMAIL'] = request.form['email']
			User['USERCREATEDTIME'] = request.form['usercreatedtime']
			return render_template(
				'userform.html',
				U=User
			)
		elif action == 'post':
			Post['PID'] = request.form['PID']
			Post['PHONE'] = request.form['PHONE']
			Post['POSTTITLE'] = request.form['POSTTITLE']
			Post['POSTTEXT'] = request.form['POSTTEXT']
			Post['PUBLISHED'] = request.form['PUBLISHED']
			Post['POSTCREATEDTIME'] = request.form['POSTCREATEDTIME']
			Post['CATEGORYTITLE'] = request.form['CATEGORYTITLE']
			return render_template(
				'postform.html',
				U=Post
			)
		else:
			return render_template('404.html'), 404
