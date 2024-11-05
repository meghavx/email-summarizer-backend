import schedule
from datetime import datetime
import time
import ollama
import json
from db_session import session
from models import StagingFAQS, FAQS
from utils import get_string_between_braces
from typing import List

def update_main_faq(mainFaqs: List[FAQS]) -> None:
    i = 0
    mainFaqString = "[\n"
    for mainFaq in mainFaqs:
        mainFaqString += (mainFaq.faq + "\n") if (i == len(mainFaqs) - 1) else (mainFaq.faq + ", \n")
        i += 1
    mainFaqString += "]"
    print(mainFaqString)
    jsonFormat = """
        { \"result\" : [
                {
                \"group\": [\"question1\",\"question2\"],
                \"generalize_question\":  \"<generalize_faq_of_all_questions_from_group>\"
                }
            ] 
        }
        """
    prompt = f"""
        From the below list, group the questions which are contextually similar to each other:
        faqs = {mainFaqString}
        Don't group questions which are not similar to each other. You can add single question in each group if none of them are 
        contextually similar to each other. Group only if they very similar to each other.
        Can you give me the result in a JSON format structured as {jsonFormat}
        """
    res = ollama.generate(model='llama3.2', prompt=prompt)
    print("res", res['response'])
    jsonRes = get_string_between_braces(res['response'])
    print("jsonRes", jsonRes)
    if (not jsonRes):
        return
    encodedJson = json.loads(jsonRes)
    resultList = encodedJson['result']
    for group in resultList:
        faq_group = group['group']
        if not faq_group:
            continue

        main_faq = faq_group[0]  # Use the first FAQ as the main FAQ
        total_count = 0
        total_percentage = 0

        faqs = session.query(FAQS).filter(FAQS.faq.in_(faq_group)).all()
        for faq in faqs:
            total_count += faq.freq
            total_percentage += faq.coverage_percentage

        main_faq_record = session.query(FAQS).filter_by(faq=main_faq).first()

        if main_faq_record:
            main_faq_record.freq = total_count
            main_faq_record.faq = group['generalize_question']
            main_faq_record.coverage_percentage = total_percentage / len(faq_group)

        for faq in faqs:
            if faq.faq != main_faq:
                session.delete(faq)

    session.commit()

def update_faq(stagingFaqs: List[StagingFAQS]) -> None:
    stagingFaqString = "[\n"
    i = 0
    for stagingFaq in stagingFaqs:
        stagingFaqString += (stagingFaq.faq + "\n") if (i == len(stagingFaqs) - 1) else (stagingFaq.faq + ".\n")

    stagingFaqString += "\n]\n"

    jsonFormat = """
        { \"result\" : [
                {
                \"group\": [\"question1\",\"question2\",...,\"questionN\"],
                \"generalize_question\":  \"<Any_one_of_faq_from_group_that_shows_intent_of_group>\"
                }
            ] 
        }
        """
    prompt = f"""
        From the below list, group the questions which are contextually similar to each other:
        faqs = {stagingFaqString}
        Can you give me the result in a JSON format structured as {jsonFormat}
        """
    res = ollama.generate(model='llama3.2', prompt=prompt)
    print("res", res['response'])
    jsonRes = get_string_between_braces(res['response'])
    print("jsonRes", jsonRes)
    if (not jsonRes):
        return
    try:
        encodedJson = json.loads(jsonRes)
    except Exception as e:
        print ("something went wrong while decoding the json",e)
        return
    resultList = encodedJson['result']
    for res in resultList:
        stagingFaqs = session.query(StagingFAQS).filter(StagingFAQS.faq.in_(res['group'])).all()
        total_percentage = 0
        coverageDescription_ = None
        for faq in stagingFaqs:
            print ("faq coverage_percentage:",faq.coverage_percentage)
            total_percentage += faq.coverage_percentage
            coverageDescription_ = faq.coverage_description

        print ("total percentage", total_percentage)
        faqRes = FAQS(
            faq=res['generalize_question'], freq=len(res['group']), coverage_percentage = total_percentage / len(res['group']),
            coverage_description = coverageDescription_
        )
        session.add(faqRes)

    session.commit()

def run_faq_consolidation() -> None:
    stagingFaqs = session.query(StagingFAQS).filter_by(
        processed_flag=False).limit(20).all()
    mainFaqs = session.query(FAQS).all()
    flag = False
    if (len(mainFaqs) > 0):
        flag = True
    update_faq(stagingFaqs)
    for staging_faq in stagingFaqs:
        staging_faq.processed_flag = True
    session.commit()
    if (flag):
        update_main_faq(mainFaqs)

def job() -> None:
    print(f"Running consolidating FAQs at {datetime.now()}")
    run_faq_consolidation()

if __name__ == '__main__':
    schedule.every(5).hours.do(job)
    job()
    while True:
        schedule.run_pending()
        time.sleep(60)
