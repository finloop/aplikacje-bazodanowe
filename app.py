import os
import psycopg2
from dotenv import load_dotenv
from flask import Flask, render_template, request, url_for, redirect

load_dotenv()  # Load .env file

POSTGRES_HOST = "localhost"
POSTGRES_DB_NAME = "postgres"
POSTGRES_USER = "postgres"
POSTGRES_PASSWORD = os.environ.get('POSTGRES_PASSWORD')


conn = psycopg2.connect(dbname=POSTGRES_DB_NAME,
                        user=POSTGRES_USER,
                        password=POSTGRES_PASSWORD,
                        host=POSTGRES_HOST)
app = Flask(__name__)

@app.route('/status')
def status():
    return "I'm alive!!!"

@app.route('/restaurants/<restaurant_id>')
def restaurant_orders(restaurant_id: int):
    """
    Handle restaurant orders

    This function by default lists orders that restaurant has
    and information about that restaurant.
    If provided with `finishorder` param it also flags that
    order as finished.
    """

    orders = {}
    restaurant = {}
    cursor = conn.cursor()

    finishorder = request.args.get('finishorder', type=int)
    if finishorder is not None:
        cursor.execute(f"CALL RESTAURANT_MAKE_ORDER_READY({finishorder})")

    # List of dishes to finish (order_id, dish_name, qty)
    cursor.execute(f"SELECT * FROM RESTAURANT_LIST_ORDERS({restaurant_id})")
    results = cursor.fetchall()
    for dish in results:
        if dish[0] not in orders.keys():
            orders[dish[0]] = [(dish[1], dish[2])]
        else:
            orders[dish[0]] += [(dish[1], dish[2])]

    # Get restaurant info
    cursor.execute(f"SELECT * FROM RESTAURANT_INFO({restaurant_id})")
    results = cursor.fetchone()
    for i, desc in enumerate(cursor.description):
        restaurant[desc[0]] = results[i]

    conn.commit()
    cursor.close()

    return render_template("restaurants.html",
                           orders=orders,
                           restaurant=restaurant,
                           restaurant_id=restaurant_id)

@app.route('/addrestaurant')
def addrestaurant():
    restaurantname = request.args.get('restaurantname')
    email = request.args.get('email')
    phonenumber = request.args.get('phonenumber')
    address = request.args.get('address')
    street = request.args.get('street')
    postalcode = request.args.get('postalcode')
    city = request.args.get('city')

    dishnames = list(map(lambda y: request.args.get(y),
                filter(lambda x: 'dishname' in x and request.args.get(x) is not '', dict(request.args))))

    dishprice = list(map(lambda y: request.args.get(y),
                filter(lambda x: 'dishprice' in x and request.args.get(x) is not '', dict(request.args))))

    dishwait = list(map(lambda y: request.args.get(y),
                filter(lambda x: 'dishwait' in x and request.args.get(x) is not '', dict(request.args))))

    dishes = [f"ARRAY{[dishnames[i], dishprice[i], dishwait[i]]}" for i in range(len(dishnames))]

    dishes = f"ARRAY{dishes}".replace("\"", "")

    cursor = conn.cursor()
    query = f"CALL RESTAURANTS_CREATE_RESTAURANT_IF_NOT_EXISTS('{restaurantname}','{email}','{phonenumber}','{address}','{street}','{postalcode}','{city}',{dishes})"
    try:
        cursor.execute(query)
        conn.commit()
        cursor.execute(f"SELECT id FROM RESTAURANTS WHERE name = '{restaurantname}'")
        restaurantid = cursor.fetchone()[0]
        return redirect(url_for(f"restaurant_orders", restaurant_id=restaurantid))
    except Exception as e:
        print(e)
        cursor.close()
        conn.rollback()
    return render_template("restaurants-create.html")
