import pandas as pd
import random
from faker import Faker
from datetime import timedelta

fake = Faker()
data = []

# Funnel stages
stages = ['Browse', 'Add to Cart', 'Checkout', 'Purchase']
stage_probs = {
    'Browse': 1.0,
    'Add to Cart': 0.7,
    'Checkout': 0.5,
    'Purchase': 0.3
}

devices = ['Mobile', 'Desktop', 'Tablet']
regions = ['North', 'South', 'East', 'West']
channels = ['Google Ads', 'Organic', 'Email', 'Social Media']
categories = ['Electronics', 'Fashion', 'Home', 'Beauty', 'Sports']

USER_COUNT = 10000

for i in range(1, USER_COUNT + 1):
    user_id = f"USR{i:05d}"
    sessions = random.randint(1, 4)

    for s in range(sessions):
        session_id = f"SES{i:05d}_{s+1}"
        event_time = fake.date_time_between(start_date='-30d', end_date='now')

        # user/session logic (UNCHANGED)
        is_first_session = (s == 0)
        user_type = 'New' if is_first_session else 'Returning'

        # session-level attributes (CRITICAL)
        channel = random.choice(channels)
        traffic_cost = round(random.uniform(20, 150), 2) if channel in ['Google Ads', 'Social Media'] else 0
        product_category = random.choice(categories)
        device = random.choice(devices)     # FIXED: one device per session
        region = random.choice(regions)     # FIXED: one region per session

        session_completed_purchase = False
        session_rows = []

        for stage in stages:
            if random.random() <= stage_probs[stage]:

                revenue = round(random.uniform(200, 2000), 2) if stage == 'Purchase' else 0
                if stage == 'Purchase':
                    session_completed_purchase = True

                session_rows.append({
                    'User_ID': user_id,
                    'Session_ID': session_id,
                    'Event': stage,
                    'Timestamp': event_time,
                    'Device': device,              # constant within session
                    'Region': region,              # constant within session
                    'Channel': channel,
                    'Product_Category': product_category,
                    'Revenue': revenue,
                    'Bounce_Flag': None,
                    'User_Type': user_type,
                    'Is_First_Session': is_first_session,
                    'Traffic_Cost': traffic_cost
                })

                event_time += timedelta(minutes=random.randint(2, 5))
                if stage == 'Purchase':
                    break
            else:
                break

        bounce_value = 'No' if session_completed_purchase else 'Yes'
        for row in session_rows:
            row['Bounce_Flag'] = bounce_value
            data.append(row)

df = pd.DataFrame(data)
df.to_csv("Funnel_Analysis_Dataset_GRANDFINAL.csv", index=False)
print("Dataset generated successfully")
